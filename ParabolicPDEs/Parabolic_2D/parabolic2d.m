%Program:       Solving 2D Parabolic Equations numerically
%Programmer:    Sammit Jain | 2014B4A30909G
%Department of Mathematics and Electrical and Electronics Engineering
%Supervisor:    Prof. D. Palla, Dept. of Mathematics, BITS Pilani
%University

%Solving 2D parabolic partial differential equations using the ADI method.
%Remark: Not sure where the different time levels are being incorporated. 
%Also ask about the clear all thing.

%clear all; 
close all;

%Assuming the domain (0,1) x (0,1) as Omega
a = 0;
b = 1;
c = 0;
d = 1;
tfinal = 1.0;

%Setting the number of points on both the axes
n = 40;
m = n;

%Setting the step size accordingly
h = (b-a)/n;

%Adjusting delta 't'
dt=0.01;

%Using h1 as h^2 for convenience
h1 = h*h;

%Setting up the levels
x=a:h:b; 
y=c:h:d;

%Initializing mu
mu = dt/(2*h1);

%-- Initial condition:

   t = 0;
   for i=1:m+1
      for j=1:m+1
         u1(i,j) = uexact_P2D(t,x(i),y(j));
      end
   end

%---------- loop for time t --------------------------------------

%Fixing the number of time levels
k_t = fix(tfinal/dt);

for k=1:k_t

%Setting up time levels k_1 and k_1/2
t1 = t + dt; t2 = t + dt/2;
%Check why this is important.
%Guess: This may be used if the question uses a term dependent on t.

%Setting up the boundary conditions
%Remark: Why can't this initialization be used outside the main loop?
%Guess: Because it's being updated in the iterative process?

    for i = 1:m+1
        u2(i,1) = 0;
        u2(i,n+1) = 0;
    end

    for j = 2:n                             % Look for fixed y(j) 

       A = sparse(m-1,m-1); 
       b1=zeros(m-1,1);
       
       for i=2:m
          b1(i-1) = mu*(u1(i,j-1) -2*u1(i,j) + u1(i,j+1))+ u1(i,j);
       end
      
     A(1,1) = (1+2*mu);
     A(1,2) = -mu;
     
     for i = 2:m-2
         A(i,i+1) = -mu;
         A(i+1,i) = -mu;
         A(i,i) = (1+2*mu);
     end
     
     A(m-1,m-2) = -mu;
     A(m-1,m-1) = (1+2*mu);

     ut = A\b1;                          % Solve the diagonal matrix.
     
     for i=1:m-1,
        u2(i+1,j) = ut(i);
     end

    end                                    % Finish x-sweep.



%-------------- loop in y -direction --------------------------------

for i = 1:m+1
    u1(1,i) = 0;
    u1(m+1,i) = 0;
end

for i = 2:m,

   A = sparse(m-1,m-1); b2=zeros(m-1,1);
   
   for j=2:n
      b2(j-1) = mu*(u2(i-1,j) -2*u2(i,j) + u2(i+1,j))+ u2(i,j);
   end
      
 A(1,1) = (1+2*mu);
 A(1,2) = -mu;
 
 for j = 2:n-2
     A(j,j+1) = -mu;
     A(j+1,j) = -mu;
     A(j,j) = (1+2*mu);
 end
 
 A(n-1,n-2) = -mu;
 A(n-1,n-1) = (1+2*mu);
 

 ut = A\b2;
 
 for j=1:n-1
    u1(i,j+1) = ut(j);
 end

 end                             

 t = t + dt;
     
end

%Initializing the exact arrray for keeping the exact values of the solution
%to the parabolic 2D equation
ue = zeros(m+1,m+1);

  for i=1:m+1,
    for j=1:n+1,
       ue(i,j) = uexact_P2D(tfinal,x(i),y(j));
    end
  end

  e = max(max(abs(u1-ue)));        % The infinity error.
 fprintf('\nThe Inf_Norm error is : %d\n',e);

 figure;
 subplot(1,2,1);
  mesh(u1);    % Plot the computed solution.
  title('Approximate solution')
 subplot(1,2,2);
 mesh(ue);          % Mesh plot of the error
  title('Exact solution')
  