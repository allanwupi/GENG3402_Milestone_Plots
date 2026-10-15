%% GENG3402 Assignment 3 - Part 3
% Authors: Allan Wu (2810308) and Bhashon Saha (25253764)
% Last updated: 15 October 2026

PROPORTIONAL_GAIN = 1;
DERIVATIVE_GAIN = -1;

% Proportional-Derivative controller: Gc(s) = Kp + Kd*s = Kd*(s + Kp/Kd)
function T = get_proportional_derivative_tf(Kp, Kd)
    s = tf('s');
    Gc = Kd*s + Kp;        % PD Compensator
    Gv = 0.6 / (3*s + 2);  % Valve
    Gp = 28 / (30*s + 2);  % Heat exchanger
    H = 2 / (5*s + 4);     % Sensor
    % Overall system transfer function T(s)
    T = Gc * Gv * Gp / (1 + Gc * Gv * Gp * H);
end


%% Function to produce annotated root locus plot
function proportional_derivative_root_locus(Kp, Kd)
    T = get_proportional_derivative_tf(Kp, Kd);
    figure;
    rlocusplot(T);
    title('Root locus of proportional-derivative controller system');
    hold on;
    p = pole(T);
    % Add labels for the pole locations
    for i = 1:length(p)
        % Print the s-domain parameters
        fprintf('s = %.0f ± j%.0f: w_n = 2pi(%.3f), w_d = 2pi(%.3f), damping = %.3f\n', ...
            real(z), imag(z), abs(z)/2/pi, imag(z)/2/pi, -real(z)/abs(z));
        text(real(p(i)), imag(p(i)), ...
        sprintf('  s_%d = %.3f%+.3fj', i, real(p(i)), imag(p(i))));
    end
    hold off;
    sgrid;
end


% Call functions using PD controller parameters
proportional_derivative_root_locus(PROPORTIONAL_GAIN, DERIVATIVE_GAIN)
