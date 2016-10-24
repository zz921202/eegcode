
y = [zeros(200,1); ones(100, 1); zeros(200,1)]%zeros(200,1); ones(50, 1); zeros(200,1);];
x = min((y + rand(500, 1)) > 0.7, 1);
pi = PerformanceEvalImp()
pi.latency(y, '', x)