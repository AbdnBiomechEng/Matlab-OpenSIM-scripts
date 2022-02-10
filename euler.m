% Euler's method

figure;

%% Plot analytical solution to see accuracy
x = (0:0.1:1);
plot(x, x.^2+2*x, '-r', 'LineWidth', 2)
text(0.1,2.4,'$y=x^2+2x$','Interpreter','latex','FontSize',24,'Color','red')
text(0.1,1.8,'${dy\over dx}=2x+2$','Interpreter','latex','FontSize',24)
hold on
xlim([0 1]); ylim([0 3]);

% Number of steps to use for integration
nsteps = 5;
y = zeros(nsteps+1,1);
x = zeros(nsteps+1,1);

% Step size
h = 1/nsteps;

% Initial value
y(1) = 0;
x(1) = 0;

% Use Euler's method for integration

for i = 1:nsteps
    
    ydot = 2*x(i)+2;
    x(i+1) = h*i;
    y(i+1) = y(i) + h*ydot;
    
end

plot(x, y, '-bo', 'MarkerFaceColor', 'blue', 'MarkerSize', 8)
text(0.5,0.5,['Nsteps = ',num2str(nsteps)],'FontSize',16)

hold off;