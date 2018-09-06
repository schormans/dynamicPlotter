function [ x,outputresults ] = dynamicplot2d( xrange, deltas, stepsize, yfunc )
%DYNAMICPLOT2D Plots a 2d function y(x) with variable x resolution
%   xrange should be a 2 element vector with the min and max of the x-range
%   of interest that you want to plot over.
%   deltas is a 2 element vector with the mindelta and maxdelta acceptable
%   in the output function yfunc. If the output diff is larger than 
%   deltas(1), the stepsize gets backed off. If the output diff is smaller
%   than deltas(2), the stepsize gets ramped up.
%   stepsize is the default step size for x, this will be ramped up or down
%   based on the gradient delta limits
%   yfunc should be a function handle to an anonymous function yfunc(x),
%   that can be crawled along dynamically

debug = true; %enables debug messages

%this sets a rough threshold for keeping inflexion points detailed, taking
%a fraction of the average delta value. This is used later for checking
%whether or not to ramp up. If f'(x) is low, the data may be uninteresting,
%but if f''(x) is greater than the defaultflexion threshold, the data is
%still considered interesting and so the stepsize should be maintained.

defaultflexion = 0.1*mean(deltas);

count = 1;
x(count) = xrange(1);
outputresults(count) = yfunc(x(count));
count = count + 1;
x(count) = x(count-1) + stepsize;
while( x(count) < xrange(2) )
    outputresults(count) = yfunc(x(count));
    absdiff(count) = abs(outputresults(count) - outputresults(count-1));
    if(count > 1)
        secondabsdiff(count-1) = abs(absdiff(count) - absdiff(count-1));
    end
    if(absdiff(count) > deltas(2)) %step too large, back off
        %backoff routine
        if(debug)
            fprintf('Backing off at count %i\n',count);
        end
        x(count) = x(count) - 0.5*stepsize;
        stepsize = 0.5*stepsize;
    elseif((absdiff(count) < deltas(1)) && (secondabsdiff(count-1)) < defaultflexion) %step too small, ramp up
    %elseif((abs(absdiff(count) - absdiff(count-1)) < defaultflexion)) %step too small, ramp up
        %rampup routine
        if(debug)
            fprintf('Ramping up at count %i\n',count);
        end
        x(count) = x(count) + 1.5*stepsize;
        stepsize = 2.5*stepsize;
    else %Step is fine, keep stepping, and increment counter
        count = count + 1;
        x(count) = x(count-1) + stepsize;
    end
end

%There is a chance that x can step over the endpoint due to stepsize
%modulation. This can result in the x vector being 1 element longer than
%the output data vector. Chop the last element if this is the case

if(length(x) > length(outputresults))
    x = x(1:end-1);
end


if(debug)
    fprintf('Done stepping, total number of point pairs: %i\n',count);
    %{
    figure
    plot(x(1:length(secondabsdiff)),secondabsdiff);
    grid on
    %}
end



end

