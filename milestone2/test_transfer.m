%% Work in Progress - Allan Wu (23810308)

%% Define transfer function
% This section uses MATLAB Symbolic Math toolbox to generate coefficients of polynomials.
% It should be removed before the submission, once we decide on the transfer function to use.
% Edit these expressions to try different transfer functions: DOMINANT_POLES, HIGHER_ORDER_POLES, ZEROS

% Set DC gain (set this to 1 to easily read percentage overshoot)
DC_GAIN = 100;
syms s
% Set dominant poles (complex conjugate pair)
DOMINANT_POLES = (s+1-4j) * (s+1+4j);
% Add nondominant poles for higher-order transfer function
HIGHER_ORDER_POLES = (s+7) * (s+5-9j) * (s+5+9j) ...
    * DOMINANT_POLES;
% Add zeros into higher-order transfer function
ZEROS = (s+5) * (s+6-8j) * (s+6+8j);

K = 1/DC_GAIN * (subs(expand(ZEROS), s, 0) / subs(expand(HIGHER_ORDER_POLES), s, 0));
denominator1 = sym2poly(K * expand(HIGHER_ORDER_POLES));
numerator1 = sym2poly(expand(ZEROS));

denominator2 = sym2poly(expand(DOMINANT_POLES));
numerator2 = sym2poly(DC_GAIN * denominator2(end) + 0*s);

%% Functions for time-domain and s-domain analysis
% Inputs: 2 transfer functions, given as arrays of numerator/denominator coefficients (descending powers)
% We define functions to get the following: 
% - Generate time-domain step response plot (transient response)
% - Generate s-domain pole-zero plot
% - Print the transient response parameters (PO, td, tr, ts, ess)
% - Print the s-domain parameters (wn, zeta) for each complex conjugate pole pair

function [S1, S2] = plot_step_response(n1, d1, n2, d2)
% Define a very fine time vector to increase the precision of step response data over defaults
    t = (0:0.0001:10)';
    sys1 = tf(n1, d1);
    sys2 = tf(n2, d2);
    % Use stepplot function provided by Control System Toolbox for unit step response
    figure;
    stepplot(sys1, sys2, t);
    set(gcf, 'Color', 'w')
    grid;
    legend('5th Order System', '2nd Order Approximation');
    hold;
    yss = n1(end) / d1(end);
    % Shade in the settling error bound (95% to 105% of final value)
    yline([yss*0.95 yss*1.05], '--', {'0.95y_{ss}', '1.05y_{ss}'}, ...
        'LabelHorizontalAlignment', 'right', 'LabelVerticalAlignment', 'middle', ...
        'HandleVisibility', 'off', 'Color', '#000000');
    p = patch([xlim fliplr(xlim)], [0.95*yss 0.95*yss 1.05*yss 1.05*yss], [1.0 0.7 0.15], ...
        'FaceAlpha', 0.08, 'EdgeColor', 'none', 'HandleVisibility', 'off');
    uistack(p, 'bottom');
    [y1, t1] = step(sys1, t);
    [y2, t2] = step(sys2, t);
    % Get step response time parameters, setting 5% as the threshold value and the exact yss value
    S1 = stepinfo(y1, t1, yss, SettlingTimeThreshold=0.05);
    S2 = stepinfo(y2, t2, yss, SettlingTimeThreshold=0.05);
    % Calculate delay times and add to step info structs
    halfYss = 0.5*yss;
    delay1 = find(y1 >= halfYss, 1, 'first');
    delay2 = find(y2 >= halfYss, 1, 'first');
    S1.DelayTime = t1(delay1);
    S2.DelayTime = t2(delay2);
    % Draw annotation lines: maximum overshoots, peak times, settling error, settling times
    yline(S1.Peak, 'LineStyle', '-.', 'HandleVisibility', 'off', 'Color', '#1171BE', ...
        'Label', sprintf('%.1f', S1.Peak), ...
        'LabelHorizontalAlignment', 'left', 'LabelVerticalAlignment', 'middle');
    xline(S1.PeakTime, 'LineStyle', '-.', 'Color', '#1171BE', 'HandleVisibility', 'off', ...
        'Label', sprintf('  %.3f', S1.PeakTime), ...
        'LabelHorizontalAlignment', 'left', 'LabelVerticalAlignment', 'bottom');
    xline(S1.SettlingTime, 'LineStyle', '-.', 'Color', '#1171BE', 'HandleVisibility', 'off', ...
        'Label', sprintf('  %.3f', S1.SettlingTime), ...
        'LabelHorizontalAlignment', 'left', 'LabelVerticalAlignment', 'bottom');
    yline(S2.Peak, 'LineStyle', '-.', 'HandleVisibility', 'off', 'Color', '#DD5400', ...
        'Label', sprintf('%.1f', S2.Peak), ...
        'LabelHorizontalAlignment', 'left', 'LabelVerticalAlignment', 'middle');
    xline(S2.PeakTime, 'LineStyle', '-.', 'Color', '#DD5400', 'HandleVisibility', 'off', ...
        'Label', sprintf('  %.3f', S2.PeakTime), ...
        'LabelHorizontalAlignment', 'right', 'LabelVerticalAlignment', 'bottom');
    xline(S2.SettlingTime, 'LineStyle', '-.', 'Color', '#DD5400', 'HandleVisibility', 'off', ...
        'Label', sprintf('  %.3f', S2.SettlingTime), ...
        'LabelHorizontalAlignment', 'left', 'LabelVerticalAlignment', 'bottom');
end

function plot_poles_zeros(n1, d1, d2)
    % Note: no need to pass in numerator of the second-order function (as there are no zeros)
    zeros = roots(n1);
    poles = roots(d1);
    dominantpoles = roots(d2);
    % Create a new figure so that the time-domain plot can be accessed separately
    figure;
    title({'Pole-Zero Plot', ''}); % Empty string in cell array adds vertical padding
    set(gcf, 'Color', 'w')
    xlabel('\sigma');
    ylabel('j\omega');
    grid;
    % Move axes to pass through the origin
    ax = gca;
    ax.XAxisLocation = 'origin';
    ax.YAxisLocation = 'origin';
    axis equal;
    % Change figure limits to square
    max_extent = max(abs(poles))+1;
    xlim([-max_extent max_extent]);
    ylim([-max_extent max_extent]);
    hold on;
    count = 0;
    for z = poles.'
        if imag(z) > 0.1
            count = count+1;
            % Draw circles of natural frequency
            r = abs(z);
            theta = 0:0.01:2*pi;
            x_circle = r * cos(theta);
            y_circle = r * sin(theta);
            plot(x_circle, y_circle, 'LineStyle', '--', 'HandleVisibility', 'off');
            text(r*0.707+0.2, r*0.707+0.2, sprintf('\\omega_{n%d} = 2\\pi\\cdot%.3f', count, r/2/pi));
        end
    end
    % Plot poles and zeros with appropriate markers
    plot(real(poles), imag(poles), 'bx', 'MarkerSize', 9, 'LineWidth', 1);
    plot(real(zeros), imag(zeros), 'bo', 'MarkerSize', 7, 'LineWidth', 1);
    plot(real(dominantpoles), imag(dominantpoles), 'rx', 'MarkerSize', 9, 'LineWidth', 1);
    legend('Poles', 'Zeros', 'Dominant Poles')
    % Add coordinate labels to all points
    poi = [zeros; poles];
    signs = repmat("+", size(poi));
    signs(imag(poi) < 0) = "-";
    labels = compose("%.0f%sj%.0f", real(poi), signs, abs(imag(poi)));
    text(real(poi), imag(poi)+1, labels, 'HorizontalAlignment', 'center', 'FontSize', 10);
end

function get_s_domain_parameters(n1, d1, n2, d2)
    sys1 = tf(n1, d1);
    sys2 = tf(n2, d2);
    fprintf("NOT IMPLEMENTED")
end

fprintf("Higher order transfer function:")
T_s = tf(numerator1, denominator1)

fprintf("Simplified lower order transfer function:")
Tdp_s = tf(numerator2, denominator2)

% Call functions
[S1, S2] = plot_step_response(numerator1, denominator1, numerator2, denominator2)
plot_poles_zeros(numerator1, denominator1, denominator2)

syms t real
expr = 1/s * expand(1/K * ZEROS / HIGHER_ORDER_POLES);
%expr = expand(1/s * 17 / (s*s + 2*s + 17))
partFracExpr = partfrac(expr, 'FactorMode', 'real');
realVal = vpa(partFracExpr, 8)

timeFunc = ilaplace(partFracExpr)
finalFunc = vpa(simplify(real(expand(timeFunc)), ...
    'IgnoreAnalyticConstraints', true), 5)
