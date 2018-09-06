% Testing dynamic plotting idea, get it working in 2d first


%if we use a high-Q resonant circuit we can get some nice example data to
%work with in the first instance

L = 10e-6;

C = 220e-12;

R = 1;

ZL = @(omega) 1j*L*omega + R;

ZC = @(omega) 1./(1j*omega*C);

%regular plot test

highres = 1000;

highresomega = 2*pi*logspace(6,8,1000);

MagZtank = abs(1./(1./ZL(highresomega) + 1./ZC(highresomega)));

%%{
figure
semilogx(highresomega,MagZtank,'-r');
grid on

%}
%{

figure
semilogx(highresomega(2:end),diff(MagZtank),'-r');
grid on
%}

%now we need to try creating a dynamic omega vector that is limited by a
%deltaZ window, which crawls the function looking for the best resolution.

maxdelta = 50;
mindelta = 20;

%deltas are in ohms here

%now we need to specify a range for our dynamic vector, and a default step
%size. We can take these from our previous highresomega vector

range = [min(highresomega) max(highresomega)];
stepsize = 20e3; %rads per sec

%Start looping and generating value pairs
%{
count = 1;
steppedomega(count) = range(1);
MagZtank(count) = abs(1/(1/ZL(steppedomega(count)) + 1/ZC(steppedomega(count))));
count = count + 1;
steppedomega(count) = steppedomega(count-1) + stepsize;
while( steppedomega(count) < range(2) )
    MagZtank(count) = abs(1/(1/ZL(steppedomega(count)) + 1/ZC(steppedomega(count))));
    absdiff = abs(MagZtank(count) - MagZtank(count-1));
    if(absdiff > maxdelta) %step too large, back off
        %backoff routine
        fprintf('Backing off at count %i\n',count);
        steppedomega(count) = steppedomega(count) - 0.5*stepsize;
        stepsize = 0.5*stepsize;
    elseif(absdiff < mindelta) %step too small, ramp up
        %rampup routine
        fprintf('Ramping up at count %i\n',count);
        steppedomega(count) = steppedomega(count) + 1.5*stepsize;
        stepsize = 2*stepsize;
    else %Step is fine, keep stepping, and increment counter
        count = count + 1;
        steppedomega(count) = steppedomega(count-1) + stepsize;
    end
    %Add a combo breaker just in case the rampup and backoff routines loop
    %somehow, if you want more than 1e6 points in a plot, a) something is
    %probably wrong, and b) change this line.
    if(count>1e6)
        fprintf('Counter overload!! Breaking!!\n');
        break
    end
end

fprintf('Done stepping, total number of point pairs: %i\n',count);

%}

MagZtankfunc = @(omega) abs(1/(1/ZL(omega) + 1/ZC(omega)));

[x,outputs] = dynamicplot2d([min(highresomega) max(highresomega)],[500 1e3],20e3,MagZtankfunc);