function [ log_kh ] = get_log_Kh( r, d )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    min_log_Kh = 0;
    max_log_Kh = 3;
    
    % For large r
    if (r > 1)
        log_kh = log(d * r) + log((1 + ((d/(d+2)*r^2))) + (d^2 * (d+8)/(((d+2) ^ 2) * (d+4)) * r^4));
    else 
    % for small r
        log_kh = (log((r * d) - r^3) -log(1 - r^2));
    end
    log_kh(find(log_kh < min_log_Kh)) = min_log_Kh;
    log_kh(find(log_kh > max_log_Kh)) = max_log_Kh;
    
    [r d log_kh]
end

