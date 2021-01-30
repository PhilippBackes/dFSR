function [ p ] = lucasKanadeForward(movImg, refImg, pInit, eps, nMax)

[height, width] = size(refImg);
center = [width-1,height-1]*0.5;
p = pInit;
n = size(p,2); % affine: 6 / translation: 2

[ gradX, gradY] = gradient(movImg);
i = 0;
q = eps+1;

syms tx ty sx sy bx by a
x = [0,0];
doTx = symfun(sx*cos(a)*x(1)-bx*sin(a)*x(2)+tx,[tx ty sx sy bx by a]);
doTy = symfun(sy*sin(a)*x(1)-by*cos(a)*x(2)+ty,[tx ty sx sy bx by a]);

while i < nMax && abs(sum(q)) > eps
    i = i+1;
    Hd = zeros(n,n);
    dp = zeros(n,1);
    
    for k = 1:height
        for l = 1:width
            x = [l,k] - center;
            xT = doTransform(p,x);
            dGrad = [linIntp(gradX,xT+center),linIntp(gradY,xT+center)];
            j = jacobian([doTx,doTy],[tx ty sx sy bx by a]);
            j = double(j(p(1),p(2),p(3),p(4),p(5),p(6),p(7)));
            s = (dGrad*j)';
            H = s*s';
            Hd = Hd + H;
            diff = refImg(k,l)-linIntp(movImg,xT+center);
            dp = dp+s*diff;
        end
    end
    
    q = pinv(Hd)*dp;
    p = p+q'
end

if i==nMax
    p = 0;
end

end

function xT = doTransform(p,x)
    tform = vec2tform(p);
    t = tform*[x,1]';
    xT = t(1:2)';
end

function tform = vec2tform(p)
    %[tx,ty,sx,sy,bx,by,a] = p(1,:);
    tT = [0 0 p(1); 0 0 p(2); 0 0 0];
    tS = [p(3) 0 0; 0 p(4) 0; 0 0 1];
    tB = [1 p(5) 0; p(6) 1 0; 0 0 1];
    tA = [cos(p(7)) -sin(p(7)) 0; sin(p(7)) cos(p(7)) 0; 0 0 1];

    tform = (tS*tB*tA)+tT;
end

function out = linIntp(in,x)
    x(x<1) = 1; x(x>size(in,1)-1)=size(in,1)-1;
    dX = [x(1)-floor(x(1)),ceil(x(1))-x(1)];
    dY = [x(2)-floor(x(2)),ceil(x(2))-x(2)];
    r = in(floor(x(2)):ceil(x(2)),floor(x(1)):ceil(x(1)));
    if sum(dX) == 0 && sum(dY) == 0
        out = in(x(2),x(1));
    elseif sum(dX) ~= 0 && sum(dY) == 0
        out = mean(dX(2)*r(1)+dX(1)*r(2));
    elseif sum(dX) == 0 && sum(dY) ~= 0
        out = mean(dY(2)*r(1)+dY(1)*r(2));
    else
        out = mean(dX(2)*mean(r(:,1))+dX(1)*mean(r(:,2))+dY(2)*mean(r(1,:))+dY(1)*mean(r(2,:)));
    end
end