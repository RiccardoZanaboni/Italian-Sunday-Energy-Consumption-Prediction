clear
clc
close all

%% Lettura dati
TabAnno1 = readtable('.\caricoITAhour.xlsx', 'Range', 'A2:D8762');
TabAnno2 = readtable('.\caricoITAhour.xlsx', 'Range', 'A8763:D17522');

TabAnno2.Properties.VariableNames = {'giorno_anno','ora_giorno', ...
                                     'giorno_settimana','dati'};
                                        
%% Selezione delle domeniche per anno
Anno1 = [TabAnno1.giorno_anno, TabAnno1.ora_giorno, TabAnno1.dati];                                 
Anno2 = [TabAnno2.giorno_anno, TabAnno2.ora_giorno, TabAnno2.dati];

domeniche_anno1 = Anno1( (TabAnno1.giorno_settimana == 1 ), :, : );
domeniche_anno2 = Anno2( (TabAnno2.giorno_settimana == 1 ), :, : );

domeniche_validazione = [domeniche_anno2];

domtot_giorno_anno = domeniche_anno1(:,1) ;
domtot_ora_giorno = domeniche_anno1(:,2) ;
domtot_dati = domeniche_anno1(:,3) ;

domtot_giorno_anno_val = domeniche_validazione(:,1) ;
domtot_ora_giorno_val = domeniche_validazione(:,2) ;
domtot_dati_val = domeniche_validazione(:,3) ;

v1 = ones( length(domtot_giorno_anno) , 1 );
v1val = ones( length(domeniche_validazione(:,3)) , 1 );
c = domtot_giorno_anno;
i = 1;
 
%% Stima del TREND e sistemazione dati
phi_trend = [v1, domtot_giorno_anno];
LS_trend = lscov(phi_trend, domtot_dati);
trend = phi_trend * LS_trend;

phi_trend_val = [v1val, domtot_giorno_anno_val];
LS_trend_val = lscov(phi_trend_val, domtot_dati_val);
trend_val = phi_trend_val * LS_trend;

%% Modello Serie di Fourier con sole ORE DEL GIORNO
phi_mod = [];
phi_mod_val = [];
NH = 3;
for NG = 3 : 25
    phi_hh = [ cos( 2 * pi/24 * domtot_ora_giorno(:)) , ...
                sin(2 * pi/24 * domtot_ora_giorno(:)) ];
                        
    phi_hh_val = [ cos(2 * pi/24 * domtot_ora_giorno_val(:)) , ...
                   sin(2 * pi/24 * domtot_ora_giorno_val(:)) ];
         
    phi_gg = [  cos(2 * pi/365 * domtot_giorno_anno(:)) , ...
                sin(2 * pi/365 * domtot_giorno_anno(:)) ];
               
    phi_gg_val = [ cos(2 * pi/365 * domtot_giorno_anno_val(:)) , ...
                   sin(2 * pi/365 * domtot_giorno_anno_val(:)) ];
                 
    for k = 2 : NH
       phi_hh = [ phi_hh , cos( k * 2 * pi/24 * domtot_ora_giorno(:)) , ...
                  sin( k * 2 * pi/24 * domtot_ora_giorno(:))  ]; 
       
       phi_hh_val = [ phi_hh_val , cos( k * 2 * pi/24 * domtot_ora_giorno_val(:)) , ...
                      sin( k * 2 * pi/24 * domtot_ora_giorno_val(:))  ];     
    end
        
    for k = 2 : NG
       phi_gg = [ phi_gg , cos( k * 2 * pi/365 * domtot_giorno_anno(:)), ...
                  sin( k * 2 * pi/365 * domtot_giorno_anno(:)) ]; 
                 
       phi_gg_val = [ phi_gg_val , cos( k * 2 * pi/365 * domtot_giorno_anno_val(:)), ...
                      sin( k * 2 * pi/365 * domtot_giorno_anno_val(:)) ]; 
    end
   
   domtot_dati = domeniche_anno1(:,3) - trend; 
   LS_mod_hh = lscov (phi_hh , domtot_dati);
   mod_hh = phi_hh * LS_mod_hh;
   domtot_dati = domtot_dati - mod_hh; %%fine foto, leva quelle '_val'
   
   domtot_dati_val = domeniche_anno2(:,3) - trend_val;
   LS_mod_hh_val = lscov (phi_hh_val , domtot_dati_val);
   mod_hh_val = phi_hh_val * LS_mod_hh;
   domtot_dati_val = domtot_dati_val - mod_hh_val;
         
   phi_mod = phi_gg;
   phi_mod_val = phi_gg_val;
    
   LS_mod = lscov (phi_mod , domtot_dati);
   mod = phi_mod * LS_mod ;
    
    residuo_val = (domtot_dati_val - phi_mod_val * LS_mod);
    SSR(i) = (residuo_val)' * (residuo_val);
    i = i + 1; 
    
%     figure(NG)
%     scatter3(domtot_giorno_anno, domtot_ora_giorno, domtot_dati, 'xgreen');
%     hold on
%     scatter3(domtot_giorno_anno, domtot_ora_giorno, FIT , '.red');
%     hold on
%     scatter3(domtot_giorno_anno, domtot_ora_giorno, mod, 'xblue');
%     grid on
% 
%     xlabel("Giorno Anno")
%     ylabel("Ora del giorno")
%     zlabel("Dati")
%     title("Stima con Fourier - Ordine =  " + NG )
%     legend("dati", "stima")
%     
end

x = 3 : 1 : NG ;
[SSR_minimo, idxm] = min(SSR);

SSR_minimo
indice_del_minimo = idxm + 2

figure()
scatter(x, SSR(:), 'xred')
hold on
scatter(indice_del_minimo, SSR_minimo, 'ob')
grid on
xlabel("Numero armoniche")
ylabel("SSRV")
title("Andamento SSR di validazione")
legend("SSRV","minimo")

%% VALIDAZIONE 
domtot_giorno_anno = domeniche_anno1(:,1);
domtot_ora_giorno = domeniche_anno1(:,2);
domtot_dati = domeniche_anno1(:,3);

domtot_giorno_anno_val = domeniche_validazione(:,1);
domtot_ora_giorno_val = domeniche_validazione(:,2);
domtot_dati_val = domeniche_validazione(:,3) ;

v1 = ones( length(domtot_giorno_anno) , 1 );
v1val = ones( length(domeniche_validazione(:,3)) , 1 );
i = 1;
c = domtot_giorno_anno;

phi_trend = [v1, domtot_giorno_anno];
LS_trend = lscov(phi_trend, domtot_dati);
trend = phi_trend * LS_trend;
domtot_dati = domtot_dati - trend;

phi_trend_val = [v1val, domtot_giorno_anno_val];
LS_trend_val = lscov(phi_trend_val, domtot_dati_val);
trend_val = phi_trend_val * LS_trend_val;
domtot_dati_val = domtot_dati_val - trend_val;

phi_mod = [];
phi_mod_val = [];
NH = 3;
NG = 10;
    
phi_hh = [ cos( 2 * pi/24 * domtot_ora_giorno(:)) , ...
            sin(2 * pi/24 * domtot_ora_giorno(:)) ];

phi_hh_val = [ cos(2 * pi/24 * domtot_ora_giorno_val(:)) , ...
               sin(2 * pi/24 * domtot_ora_giorno_val(:)) ];

phi_gg = [  cos(2 * pi/365 * domtot_giorno_anno(:)) , ...
            sin(2 * pi/365 * domtot_giorno_anno(:)) ];

phi_gg_val = [ cos(2 * pi/365 * domtot_giorno_anno_val(:)) , ...
               sin(2 * pi/365 * domtot_giorno_anno_val(:)) ];

for k = 2 : NH
   phi_hh = [ phi_hh , cos( k * 2 * pi/24 * domtot_ora_giorno(:)) , ...
              sin( k * 2 * pi/24 * domtot_ora_giorno(:))  ]; 

   phi_hh_val = [ phi_hh_val , cos( k * 2 * pi/24 * domtot_ora_giorno_val(:)) , ...
                  sin( k * 2 * pi/24 * domtot_ora_giorno_val(:))  ]; 
end

for k = 2 : NG
   phi_gg = [ phi_gg , cos( k * 2 * pi/365 * domtot_giorno_anno(:)), ...
              sin( k * 2 * pi/365 * domtot_giorno_anno(:)) ]; 

   phi_gg_val = [ phi_gg_val , cos( k * 2 * pi/365 * domtot_giorno_anno_val(:)), ...
                  sin( k * 2 * pi/365 * domtot_giorno_anno_val(:)) ]; 
end

LS_mod_hh = lscov (phi_hh , domtot_dati);
mod_hh = phi_hh_val * LS_mod_hh;
domtot_dati = domeniche_anno1(:,3) - mod_hh;

LS_mod = lscov (phi_gg , domtot_dati);
mod_gg = phi_gg_val * LS_mod ;

figure(50)
scatter3(domtot_giorno_anno_val, domtot_ora_giorno_val, domtot_dati_val + trend_val, 'xgreen');
hold on
scatter3(domtot_giorno_anno_val, domtot_ora_giorno_val, mod_gg + mod_hh + trend_val, 'xblue');
grid on
xlabel("Giorno Anno")
ylabel("Ora del giorno")
zlabel("Dati")
title("Stima con Fourier - VALIDAZIONE " )
legend("dati", "stima")