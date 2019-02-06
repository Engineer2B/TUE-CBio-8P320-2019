classdef TheoreticalStuffForReference2 < handle
	properties
		Speed
		Attenuation
		f
		omega
		c_g
		rho_g
		alpha_g
		k_g
		lambda_g
		xi_g
		cS
		cL
		rho_s
		alphaS
		alphaL
		kS
		kL
		mu
		eta
		p1
		p2
		lambda
		xi
		Z_g
		Const1
		Const2
		Const3
		Const4
		Const5
		Const6
		Const7
	end
	methods(Static)
		function obj = Get()
			obj = Single.Demo.TheoreticalStuffForReference2();
			obj.f = 1.2e6; % Hz, US frequency
			obj.omega = 2*pi*obj.f; % angular freq
			obj.c_g = 1537; % m/s, speed of longitudinal waves in gel
			obj.rho_g = 1000; % kg/m3, density of gel
			obj.alpha_g = 5.76; % /m, attenuation of gel, in Nepers
			obj.k_g = obj.omega/obj.c_g; % wave number
			[obj.lambda_g, obj.xi_g] = obj.FSolvepars(obj.rho_g, obj.omega,...
				obj.c_g, obj.alpha_g);
			obj.cS = 1995; % m/s, speed of shear waves in bone
			obj.cL = 3736; % m/s, speed of longit waves in bone
			obj.rho_s = 2025; % kg/m3, density of bone
			obj.alphaS = 322; % /m, attenuation of shear waves in bone, in Nepers
			obj.alphaL = 222; % /m, attenuation of longit waves in bone, in Nepers
			obj.kS = obj.omega/obj.cS;
			obj.kL = obj.omega/obj.cL;
			% compute for bone mu and lambda(Lam par) and xi:
			[obj.mu, obj.eta] = obj.FSolvepars(obj.rho_s, obj.omega, obj.cS,...
				obj.alphaS);
			% next: compute p1=lambda+2 mu and p2=xi+4 eta/3:
			[obj.p1,obj.p2]= obj.FSolvepars(obj.rho_s, obj.omega, obj.cL,...
				obj.alphaL);
			obj.lambda=obj.p1-2*obj.mu;
			obj.xi=obj.p2-4*obj.eta/3;
			% Define other constants
			% for liquid (gel):
			obj.Z_g= obj.rho_g*obj.c_g; % acoustic impedance of gel
			obj.Const1=obj.xi_g*obj.omega^2/(2*(obj.lambda_g^2+...
				obj.omega^2*obj.xi_g^2));
			% for solid (bone), longitudinal:
			obj.Const2=obj.omega*((obj.lambda+2*obj.mu)*obj.kL+...
				(obj.xi+4*obj.eta/3)*obj.omega*obj.alphaL)/2;
			obj.Const3=1/obj.Const2;
			obj.Const4=(-1i*obj.omega)*(1i*obj.kL-obj.alphaL); % complex constant
			% for solid (bone), shear:
			obj.Const5=(obj.mu*obj.omega*obj.kS+...
				obj.eta*obj.omega^2*obj.alphaS)/2;
			obj.Const6=1/obj.Const5;
			obj.Const7=(-1i*obj.omega)*(1i*obj.kS-obj.alphaS);% complex constant
			generateWaveTypeVar = @(shearVal, longitudinalVal) struct(...
				'Shear', shearVal, 'Longitudinal', longitudinalVal);
			obj.Speed = generateWaveTypeVar(obj.cS, obj.cL);
			obj.Attenuation =  generateWaveTypeVar(obj.alphaS, obj.alphaL);
		end
	end
	methods(Access = public, Static)
		function [p_1, p_2] = FSolvepars(rho, omega, speed, alpha)
			k = omega/speed; % wave number
			C = omega^2*rho/(alpha^2+ k^2);
			D = sqrt(2)*C/(speed*sqrt(rho));
			p_1 = D^2-C;
			p_2 = sqrt(C^2-p_1^2)/omega; % Originally, Huub ten Eikelder's
			% document "Theoretical stuff for reference II" had the following
			% assignment: p_2 = sqrt(C^2-p_elast^2)/omega;
		end
	end
	methods(Access = protected)
		function obj = TheoreticalStuffForReference2()
		end
	end
end

