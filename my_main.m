clear all; close all; clc;    
%% 原始信号生成与突变点的添加
Fs = 1000;                % 采样频率1000Hz
Ts = 1 / Fs;              % 采样时间间隔1ms
L = 1000;                 % 采样点数1000
t = (0 : L - 1) * Ts;     % 采样时间。1000个点，每个点1ms，相当于采集了1s
x = sin(2 * pi * 10 * t); % 原始正弦信号，频率为10Hz
% x = x + 0.1 .* randn(1,1000); % 添加噪声
x(233) = x(233) + 0.5;    % 添加突变点
x(666) = x(666) + 0.1;

figure(1); 
plot(x)
xlabel('采样点数(1ms/点)');ylabel('幅值'); 
title('突变信号');       

%% 傅里叶变换观察突变信号频谱
Y = fft(x,1024); % 对信号进行傅里叶变换
f = Fs * (0 : (L / 2)) / L;
P2 = abs(Y / L);
P1 = P2(1 : L / 2 + 1);
figure(2)
plot(f,P1) 
title('突变信号的单边幅度频谱')
xlabel('f(Hz)')
ylabel('|P1(f)|')
axis([0,100,0,0.5])

%% 连续小波变换(CWT)
figure(3)
cw1 = cwt(x,1:32,'sym2','plot'); % 对信号做连续小波变换，并作出系数图像
title('连续小波变换系数图');


%% 离散小波变换(DWT) Wallat算法
%法一：直接用wavedec()进行3层分解，再重构生成近似系数和细节系数
[d,a]=wavedec(x,3,'db4');           %对原始信号进行3层离散小波分解
a3=wrcoef('a',d,a,'db4',3);         %重构第3层近似系数
d3=wrcoef('d',d,a,'db4',3);         %重构第3层细节系数  
d2=wrcoef('d',d,a,'db4',2);         %重构第2层细节系数  
d1=wrcoef('d',d,a,'db4',1);         %重构第1层细节系数  

figure(4); 
subplot(411);plot(a3);ylabel('近似信号a3');   %画出各层小波系数
title('小波分解示意图(方法一)');
subplot(412);plot(d3);ylabel('细节信号d3');
subplot(413);plot(d2);ylabel('细节信号d2');
subplot(414);plot(d1);ylabel('细节信号d1');
xlabel('时间'); 

%% 离散小波变换(DWT) Wallat算法
% 法二：用dwt()一层一层分解生成近似系数和细节系数
[ca11,cd1] = dwt(x,'db4');      % 第1层分解
[ca22,cd2] = dwt(ca11,'db4');   % 第2层分解
[ca3,cd3] = dwt(ca22,'db4');    % 第3层分解

figure(5)
subplot(511);plot(x);    % 画出各层小波系数，注意由于函数自带下采样，所以每层系数长度会减半
title('原始信号x');            
subplot(512);plot(ca3);         
title('近似系数ca3');
subplot(513);plot(cd3);
title('细节系数cd3');
subplot(514);plot(cd2);
title('细节系数cd2');
subplot(515);plot(cd1);
title('细节系数cd1');
xlabel('时间'); 

% 为了与法一做对比，把系数又上采样回1000点，和figure(4)图像比较
cd_1 = dyadup(cd1);         % 上采样到1000个点
cd_2 = dyadup(dyadup(cd2)); % 上采样到1000个点
cd_3 = dyadup(dyadup(dyadup(cd3))); % 上采样到1000个点
ca_3 = dyadup(dyadup(dyadup(ca3))); % 上采样到1000个点

figure(6)
subplot(411);plot(ca_3);ylabel('近似信号a3');   %画出各层小波系数
title('小波分解示意图(方法二)');
axis([0 1000 -2 2]);
subplot(412);plot(cd_3);ylabel('细节信号d3');
axis([0 1000 -0.1 0.1]);
subplot(413);plot(cd_2);ylabel('细节信号d2');
axis([0 1000 -0.2 0.2]);
subplot(414);plot(cd_1);ylabel('细节信号d1');
axis([0 1000 -0.5 0.5]);
xlabel('时间'); 