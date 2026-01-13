function uydu_analiz_paketi_V5_DINAMIK_OPT_LIGHT_RSSI_SON
  
    % --- RENKLER VE STİLLER (MEVCUT YAPI KORUNDU) ---
    renkler = struct();
    renkler.arka_plan = [0.85, 0.95, 1.0];      
    renkler.baslik = [0.5, 0.0, 0.5];           
    renkler.buton_ana = [1.0, 0.4, 0.0];        
    renkler.buton_aksiyon = [0.0, 0.7, 0.3];    
    renkler.cizgi = [1.0, 0.0, 0.5];            
    
    renkler.tab1 = [1.0, 1.0, 0.7];             
    renkler.tab2 = [0.7, 1.0, 0.7];             
    renkler.tab3 = [1.0, 0.8, 1.0];             
    renkler.tab_opt = [0.7, 0.8, 1.0];          
    
    renkler.tab_lazer_bg = [0.9, 0.8, 1.0];     
    renkler.opt_panel_bg = [1.0, 0.95, 0.8];    
    renkler.opt_yazi     = [0.0, 0.0, 0.0];     
    renkler.opt_buton    = [0.8, 0.2, 0.8];     
    renkler.opt_sonuc_bg = [1.0, 1.0, 1.0];     
    
    renkler.panel_mavi_koyu = [0.0, 0.8, 0.8];    
    renkler.panel_mor = [1.0, 0.8, 0.0];          
    renkler.panel_turuncu = [0.7, 0.6, 1.0];      
    renkler.panel_yesil_koyu = [0.6, 0.8, 1.0];   
    renkler.panel_kirmizi = [1.0, 0.7, 0.7];      
    renkler.panel_sari_koyu = [0.9, 0.9, 0.5];    
    renkler.panel_turkuaz = [0.5, 1.0, 1.0];      
    
    % --- VERİ YAPISI İLKLEMESİ ---
    persistent uyduVerileri;
    if isempty(uyduVerileri)
        uyduVerileri.sistem = struct('uyduAdi', 'Gül', 'siteAdi', 'Selçuklu', 'band', 1, 'antenTipi', 1, ...
                                     'uydu_enlem', 40.0, 'uydu_boylam', 32.0, 'uydu_irtifa', 600000.0, ... 
                                     'yer_enlem', 37.9, 'yer_boylam', 32.5, 'yer_irtifa', 100.0);       
        uyduVerileri.verici = struct('frekans', 0.433, 'guc', 0.1, 'capT', 0.17, 'txKayip', 1, 'bantGenisligi', 0.125, 'modKayip', 1, 'kodlamaKazanci', 0.0); 
        
        uyduVerileri.alici = struct('esikSN', 5, 'capR', 0.5, 'rxKayip', 2, 'sicaklik', 290, ...
                                    'interferenceLoss', 2.0, 'gtTarget', 25.0, 'rxFeederLoss', 1.0, 'otherRxLoss', 1.0); 
        
        uyduVerileri.kayiplar = struct('fsl', 110, 'polarizasyon', 0.5, 'yonlendirme', 0.2, 'yagmur', 0.0, 'gaz', 0.0, 'diger', 2.0);
        uyduVerileri.sonuclar = []; 
        uyduVerileri.sim_results = [];
        uyduVerileri.optik = struct('dalga', 1550, 'guc', 1.0, 'txCap', 10, 'rxCap', 30, 'mesafe', 600, 'huzme', 0.05, 'hata', 0.01, 'atm', 3.0, 'sens', -45);
    end
    
    handles = struct();
    
    % --- ANA ARAYÜZ ---
    handles.anaMenu = figure('Name', 'Link Budget Analizi', 'NumberTitle', 'off', ...
                             'Position', [100, 100, 1000, 750], 'Color', renkler.arka_plan, 'MenuBar', 'none');
    
    uicontrol('Parent', handles.anaMenu, 'Style', 'text', 'String', 'Link Bütçesi Analiz Uygulaması', 'FontSize', 22, 'FontWeight', 'bold', ...
              'Position', [0, 700, 1000, 40], 'BackgroundColor', renkler.arka_plan, 'ForegroundColor', renkler.baslik);
    
    uicontrol('Parent', handles.anaMenu, 'Style', 'pushbutton', 'String', 'GİRDİLERİ KAYDET ve HESAPLA', 'FontSize', 14, 'FontWeight', 'bold', ...
              'Position', [250, 650, 300, 40], 'BackgroundColor', renkler.buton_ana, 'ForegroundColor', 'w', 'Callback', @kaydet_ve_hesapla_callback);
    uicontrol('Parent', handles.anaMenu, 'Style', 'pushbutton', 'String', 'Senaryo Kaydet', 'FontSize', 10, ...
              'Position', [560, 650, 120, 40], 'BackgroundColor', renkler.buton_ana, 'Callback', @senaryo_kaydet);
    
    handles.link_durumu_panel = uipanel('Parent', handles.anaMenu, 'Position', [700, 650, 180, 40], 'BackgroundColor', renkler.arka_plan, 'Title', 'Link Durumu (Maks. İrtifa)');
    handles.link_durumu_text = uicontrol('Parent', handles.link_durumu_panel, 'Style', 'text', 'String', 'HESAPLANMADI', 'FontSize', 12, 'FontWeight', 'bold', ...
                                         'Position', [0, 0, 178, 20]);
    
    handles.ana_tab_grubu = uitabgroup(handles.anaMenu, 'Position', [0.02, 0.02, 0.96, 0.82]);
    
    % --- TAB 1 ---
    handles.tab_giris = uitab(handles.ana_tab_grubu, 'Title', '1. Ana Girişler', 'BackgroundColor', renkler.tab1);
    
    pnl_sistem = uipanel(handles.tab_giris, 'Title', 'Sistem Bilgileri ve Coğrafi Konum (WGS84)', 'FontWeight', 'bold', 'Position', [0.03, 0.57, 0.94, 0.38], 'BackgroundColor', renkler.tab1);
        y_pos = 165; dy = 30;
        uicontrol(pnl_sistem, 'Style', 'text', 'String', 'Uydu Adı:', 'Position', [20, y_pos, 140, 20], 'BackgroundColor', renkler.tab1, 'HorizontalAlignment', 'left');
        handles.h_sistem_uyduAdi = uicontrol(pnl_sistem, 'Style', 'edit', 'String', uyduVerileri.sistem.uyduAdi, 'Position', [170, y_pos, 200, 22]);
        uicontrol(pnl_sistem, 'Style', 'text', 'String', 'İstasyon Anten Tipi:', 'Position', [450, y_pos, 140, 20], 'BackgroundColor', renkler.tab1, 'HorizontalAlignment', 'left');
        handles.h_sistem_antenTipi = uicontrol(pnl_sistem, 'Style', 'popupmenu', 'String', {'Yagi (7 dBi)', 'Parabol (1.2m)', 'Patch (5 dBi)', 'Turnstile (3 dBi)', 'Dipole (2 dBi)'}, 'Value', uyduVerileri.sistem.antenTipi, 'Position', [600, y_pos, 200, 22]);
        y_pos=y_pos-dy;
        uicontrol(pnl_sistem, 'Style', 'text', 'String', 'Yer İstasyonu:', 'Position', [20, y_pos, 140, 20], 'BackgroundColor', renkler.tab1, 'HorizontalAlignment', 'left');
        handles.h_sistem_siteAdi = uicontrol(pnl_sistem, 'Style', 'edit', 'String', uyduVerileri.sistem.siteAdi, 'Position', [170, y_pos, 200, 22]);
        uicontrol(pnl_sistem, 'Style', 'text', 'String', 'Frekans Bandı:', 'Position', [450, y_pos, 140, 20], 'BackgroundColor', renkler.tab1, 'HorizontalAlignment', 'left');
        handles.h_sistem_band = uicontrol(pnl_sistem, 'Style', 'popupmenu', 'String', {'VHF', 'UHF (433MHz)', 'UHF (868MHz)', 'L-Band', 'S-Band', 'C-Band', 'X-Band', 'Ku-Band', 'Ka-Band'}, 'Value', uyduVerileri.sistem.band, 'Position', [600, y_pos, 200, 22]);
        y_pos=y_pos-dy;
        y_pos = 95;
        uicontrol(pnl_sistem, 'Style', 'text', 'String', '--- Uydu Konumu (P₂: φ₂, λ₂, h₂) ---', 'Position', [20, y_pos, 390, 20], 'BackgroundColor', renkler.tab1, 'FontWeight', 'bold', 'HorizontalAlignment', 'left');
        uicontrol(pnl_sistem, 'Style', 'text', 'String', '--- Yer İstasyonu (P₁: φ₁, λ₁, h₁) ---', 'Position', [450, y_pos, 390, 20], 'BackgroundColor', renkler.tab1, 'FontWeight', 'bold', 'HorizontalAlignment', 'left');
        y_pos = 65;
        uicontrol(pnl_sistem, 'Style', 'text', 'String', 'Enlem (φ) [deg]:', 'Position', [20, y_pos, 100, 20], 'BackgroundColor', renkler.tab1, 'HorizontalAlignment', 'left');
        handles.h_sistem_uyduEnlem = uicontrol(pnl_sistem, 'Style', 'edit', 'String', num2str(uyduVerileri.sistem.uydu_enlem), 'Position', [120, y_pos, 70, 22]);
        uicontrol(pnl_sistem, 'Style', 'text', 'String', 'Boylam (λ) [deg]:', 'Position', [195, y_pos, 100, 20], 'BackgroundColor', renkler.tab1, 'HorizontalAlignment', 'left');
        handles.h_sistem_uyduBoylam = uicontrol(pnl_sistem, 'Style', 'edit', 'String', num2str(uyduVerileri.sistem.uydu_boylam), 'Position', [295, y_pos, 70, 22]);
        uicontrol(pnl_sistem, 'Style', 'text', 'String', 'İrtifa (h) [m]:', 'Position', [370, y_pos, 80, 20], 'BackgroundColor', renkler.tab1, 'HorizontalAlignment', 'left');
        handles.h_sistem_uydu_irtifa = uicontrol(pnl_sistem, 'Style', 'edit', 'String', num2str(uyduVerileri.sistem.uydu_irtifa), 'Position', [450, y_pos, 100, 22]);
        y_pos = 35;
        uicontrol(pnl_sistem, 'Style', 'text', 'String', 'Enlem (φ) [deg]:', 'Position', [580, y_pos, 100, 20], 'BackgroundColor', renkler.tab1, 'HorizontalAlignment', 'left');
        handles.h_sistem_yerEnlem = uicontrol(pnl_sistem, 'Style', 'edit', 'String', num2str(uyduVerileri.sistem.yer_enlem), 'Position', [680, y_pos, 70, 22]);
        uicontrol(pnl_sistem, 'Style', 'text', 'String', 'Boylam (λ) [deg]:', 'Position', [755, y_pos, 100, 20], 'BackgroundColor', renkler.tab1, 'HorizontalAlignment', 'left');
        handles.h_sistem_yerBoylam = uicontrol(pnl_sistem, 'Style', 'edit', 'String', num2str(uyduVerileri.sistem.yer_boylam), 'Position', [855, y_pos, 70, 22]);
        uicontrol(pnl_sistem, 'Style', 'text', 'String', 'İrtifa (h) [m]:', 'Position', [580, 5, 80, 20], 'BackgroundColor', renkler.tab1, 'HorizontalAlignment', 'left');
        handles.h_sistem_yer_irtifa = uicontrol(pnl_sistem, 'Style', 'edit', 'String', num2str(uyduVerileri.sistem.yer_irtifa), 'Position', [680, 5, 70, 22]);
    pnl_verici = uipanel(handles.tab_giris, 'Title', 'Verici Parametreleri (Uydu)', 'FontWeight', 'bold', 'Position', [0.03, 0.03, 0.45, 0.52], 'BackgroundColor', renkler.tab1);
        y_pos = 230; dy = 30;
        uicontrol(pnl_verici, 'Style', 'text', 'String', 'Frekans (GHz):', 'Position', [20, y_pos, 150, 20], 'BackgroundColor', renkler.tab1, 'HorizontalAlignment', 'left');
        handles.h_verici_frekans = uicontrol(pnl_verici, 'Style', 'edit', 'String', num2str(uyduVerileri.verici.frekans), 'Position', [180, y_pos, 180, 22]); y_pos=y_pos-dy;
        uicontrol(pnl_verici, 'Style', 'text', 'String', 'Güç (W):', 'Position', [20, y_pos, 150, 20], 'BackgroundColor', renkler.tab1, 'HorizontalAlignment', 'left');
        handles.h_verici_guc = uicontrol(pnl_verici, 'Style', 'edit', 'String', num2str(uyduVerileri.verici.guc), 'Position', [180, y_pos, 180, 22]); y_pos=y_pos-dy;
        uicontrol(pnl_verici, 'Style', 'text', 'String', 'Verici Anten Ölçüsü (m):', 'Position', [20, y_pos, 150, 20], 'BackgroundColor', renkler.tab1, 'HorizontalAlignment', 'left');
        handles.h_verici_capT = uicontrol(pnl_verici, 'Style', 'edit', 'String', num2str(uyduVerileri.verici.capT), 'Position', [180, y_pos, 180, 22]); y_pos=y_pos-dy;
        uicontrol(pnl_verici, 'Style', 'text', 'String', 'Verici Besleme Kaybı (dB):', 'Position', [20, y_pos, 150, 20], 'BackgroundColor', renkler.tab1, 'HorizontalAlignment', 'left');
        handles.h_verici_txKayip = uicontrol(pnl_verici, 'Style', 'edit', 'String', num2str(uyduVerileri.verici.txKayip), 'Position', [180, y_pos, 180, 22]); y_pos=y_pos-dy;
        uicontrol(pnl_verici, 'Style', 'text', 'String', 'Modülasyon Kaybı (dB):', 'Position', [20, y_pos, 150, 20], 'BackgroundColor', renkler.tab1, 'HorizontalAlignment', 'left');
        handles.h_verici_modKayip = uicontrol(pnl_verici, 'Style', 'edit', 'String', num2str(uyduVerileri.verici.modKayip), 'Position', [180, y_pos, 180, 22]); y_pos=y_pos-dy;
        uicontrol(pnl_verici, 'Style', 'text', 'String', 'Bant Genişliği (MHz):', 'Position', [20, y_pos, 150, 20], 'BackgroundColor', renkler.tab1, 'HorizontalAlignment', 'left');
        handles.h_verici_bantGenisligi = uicontrol(pnl_verici, 'Style', 'edit', 'String', num2str(uyduVerileri.verici.bantGenisligi), 'Position', [180, y_pos, 180, 22]); y_pos=y_pos-dy;
        uicontrol(pnl_verici, 'Style', 'text', 'String', 'Kodlama Kazancı (dB):', 'Position', [20, y_pos, 150, 20], 'BackgroundColor', renkler.tab1, 'HorizontalAlignment', 'left'); 
        handles.h_verici_kodlamaKazanci = uicontrol(pnl_verici, 'Style', 'edit', 'String', num2str(uyduVerileri.verici.kodlamaKazanci), 'Position', [180, y_pos, 180, 22]); 
    pnl_alici = uipanel(handles.tab_giris, 'Title', 'Alıcı Parametreleri (Yer İstasyonu)', 'FontWeight', 'bold', 'Position', [0.52, 0.03, 0.45, 0.52], 'BackgroundColor', renkler.tab1);
        y_pos = 230; dy = 30;
        uicontrol(pnl_alici, 'Style', 'text', 'String', 'Eşik S/N Oranı (dB):', 'Position', [20, y_pos, 150, 20], 'BackgroundColor', renkler.tab1, 'HorizontalAlignment', 'left');
        handles.h_alici_esikSN = uicontrol(pnl_alici, 'Style', 'edit', 'String', num2str(uyduVerileri.alici.esikSN), 'Position', [180, y_pos, 180, 22]); y_pos=y_pos-dy;
        uicontrol(pnl_alici, 'Style', 'text', 'String', 'Alıcı Anten Ölçüsü (m):', 'Position', [20, y_pos, 150, 20], 'BackgroundColor', renkler.tab1, 'HorizontalAlignment', 'left');
        handles.h_alici_capR = uicontrol(pnl_alici, 'Style', 'edit', 'String', num2str(uyduVerileri.alici.capR), 'Position', [180, y_pos, 180, 22]); y_pos=y_pos-dy;
        uicontrol(pnl_alici, 'Style', 'text', 'String', 'Sistem Gürültü Sıcaklığı (K):', 'Position', [20, y_pos, 150, 20], 'BackgroundColor', renkler.tab1, 'HorizontalAlignment', 'left');
        handles.h_alici_sicaklik = uicontrol(pnl_alici, 'Style', 'edit', 'String', num2str(uyduVerileri.alici.sicaklik), 'Position', [180, y_pos, 180, 22]); y_pos=y_pos-dy;
        uicontrol(pnl_alici, 'Style', 'text', 'String', 'Parazit Kaybı (Interf.) (dB):', 'Position', [20, y_pos, 150, 20], 'BackgroundColor', renkler.tab1, 'HorizontalAlignment', 'left');
        handles.h_alici_interference = uicontrol(pnl_alici, 'Style', 'edit', 'String', num2str(uyduVerileri.alici.interferenceLoss), 'Position', [180, y_pos, 180, 22]); y_pos=y_pos-dy;
        uicontrol(pnl_alici, 'Style', 'text', 'String', 'Rx Feeder Kaybı (dB):', 'Position', [20, y_pos, 150, 20], 'BackgroundColor', renkler.tab1, 'HorizontalAlignment', 'left');
        handles.h_alici_feederLoss = uicontrol(pnl_alici, 'Style', 'edit', 'String', num2str(uyduVerileri.alici.rxFeederLoss), 'Position', [180, y_pos, 180, 22]); y_pos=y_pos-dy;
        uicontrol(pnl_alici, 'Style', 'text', 'String', 'Diğer Rx Kayıpları (dB):', 'Position', [20, y_pos, 150, 20], 'BackgroundColor', renkler.tab1, 'HorizontalAlignment', 'left');
        handles.h_alici_otherLoss = uicontrol(pnl_alici, 'Style', 'edit', 'String', num2str(uyduVerileri.alici.otherRxLoss), 'Position', [180, y_pos, 180, 22]); y_pos=y_pos-dy;
        uicontrol(pnl_alici, 'Style', 'text', 'String', 'G/T Hedef (dB/K):', 'Position', [20, y_pos, 150, 20], 'BackgroundColor', renkler.tab1, 'HorizontalAlignment', 'left');
        handles.h_alici_gtTarget = uicontrol(pnl_alici, 'Style', 'edit', 'String', num2str(uyduVerileri.alici.gtTarget), 'Position', [180, y_pos, 180, 22]);
    
    % --- TAB 2 ---
    handles.tab_hesap = uitab(handles.ana_tab_grubu, 'Title', '2. Detaylı Hesaplayıcılar', 'BackgroundColor', renkler.tab2);
    handles.ic_tab_grubu = uitabgroup(handles.tab_hesap, 'Position', [0.01, 0.01, 0.98, 0.98]);
    
    ic_tab_kayip = uitab(handles.ic_tab_grubu, 'Title', 'Kayıp Hesaplayıcıları', 'BackgroundColor', renkler.tab2);
        pnl_W = 0.3; pnl_H = 0.45; x_gap = 0.02; y_gap = 0.02;
        x1 = 0.02; x2 = x1+pnl_W+x_gap; x3 = x2+pnl_W+x_gap;
        y1 = 0.52; y2 = y1-pnl_H-y_gap;
        pnl_fsl = uipanel(ic_tab_kayip, 'Title', 'Serbest Uzay Kaybı (FSL)', 'Position', [x1, y1, pnl_W, pnl_H], 'BackgroundColor', renkler.panel_mavi_koyu);
            uicontrol(pnl_fsl, 'Style', 'text', 'String', 'Distance (km):', 'Position', [10, 190, 120, 20], 'BackgroundColor', renkler.panel_mavi_koyu);
            handles.h_fsl_mesafe = uicontrol(pnl_fsl, 'Style', 'edit', 'String', '4', 'Position', [140, 190, 100, 22]);
            uicontrol(pnl_fsl, 'Style', 'text', 'String', 'Frekans (GHz):', 'Position', [10, 160, 120, 20], 'BackgroundColor', renkler.panel_mavi_koyu);
            handles.h_fsl_frekans = uicontrol(pnl_fsl, 'Style', 'edit', 'String', num2str(uyduVerileri.verici.frekans), 'Position', [140, 160, 100, 22]);
            uicontrol(pnl_fsl, 'Style', 'pushbutton', 'String', 'Hesapla ve Ekle', 'Position', [70, 120, 140, 30], 'BackgroundColor', renkler.buton_aksiyon, 'ForegroundColor', 'w', 'Callback', @hesapla_fsl_callback);
            uicontrol(pnl_fsl, 'Style', 'text', 'String', 'FSL (dB) = 92.45 + 20log10(d) + 20log10(f)', 'Position', [10, 80, 260, 20], 'BackgroundColor', renkler.panel_mavi_koyu);
            uicontrol(pnl_fsl, 'Style', 'text', 'String', 'Sonuç (dB):', 'FontWeight', 'bold', 'Position', [10, 40, 120, 20], 'BackgroundColor', renkler.panel_mavi_koyu);
            handles.h_fsl_sonuc = uicontrol(pnl_fsl, 'Style', 'text', 'String', '', 'Position', [140, 40, 100, 20], 'FontWeight', 'bold', 'ForegroundColor', renkler.baslik);
        pnl_pol = uipanel(ic_tab_kayip, 'Title', 'Polarizasyon Kaybı', 'Position', [x2, y1, pnl_W, pnl_H], 'BackgroundColor', renkler.panel_mor);
            uicontrol(pnl_pol, 'Style', 'text', 'String', 'Angle (derece):', 'Position', [10, 190, 120, 20], 'BackgroundColor', renkler.panel_mor);
            handles.h_pol_aci = uicontrol(pnl_pol, 'Style', 'edit', 'String', '30', 'Position', [140, 190, 100, 22]);
            uicontrol(pnl_pol, 'Style', 'pushbutton', 'String', 'Hesapla ve Ekle', 'Position', [70, 120, 140, 30], 'BackgroundColor', renkler.buton_aksiyon, 'ForegroundColor', 'w', 'Callback', @hesapla_pol_callback);
            uicontrol(pnl_pol, 'Style', 'text', 'String', 'Loss (dB) = -20 * log10(cosd(açı))', 'Position', [10, 80, 260, 20], 'BackgroundColor', renkler.panel_mor);
            uicontrol(pnl_pol, 'Style', 'text', 'String', 'Sonuç (dB):', 'FontWeight', 'bold', 'Position', [10, 40, 120, 20], 'BackgroundColor', renkler.panel_mor);
            handles.h_pol_sonuc = uicontrol(pnl_pol, 'Style', 'text', 'String', '', 'Position', [140, 40, 100, 20], 'FontWeight', 'bold', 'ForegroundColor', renkler.baslik);
        pnl_point = uipanel(ic_tab_kayip, 'Title', 'Yönlendirme Kaybı', 'Position', [x3, y1, pnl_W, pnl_H], 'BackgroundColor', renkler.panel_turuncu);
            uicontrol(pnl_point, 'Style', 'text', 'String', 'Antenna Diameter (m):', 'Position', [10, 190, 120, 20], 'BackgroundColor', renkler.panel_turuncu, 'HorizontalAlignment','left');
            handles.h_point_cap = uicontrol(pnl_point, 'Style', 'edit', 'String', num2str(uyduVerileri.alici.capR), 'Position', [140, 190, 100, 22]);
            uicontrol(pnl_point, 'Style', 'text', 'String', 'Frekans (GHz):', 'Position', [10, 160, 120, 20], 'BackgroundColor', renkler.panel_turuncu, 'HorizontalAlignment','left');
            handles.h_point_frekans = uicontrol(pnl_point, 'Style', 'edit', 'String', num2str(uyduVerileri.verici.frekans), 'Position', [140, 160, 100, 22]);
            uicontrol(pnl_point, 'Style', 'text', 'String', 'Angle Error (derece):', 'Position', [10, 130, 120, 20], 'BackgroundColor', renkler.panel_turuncu, 'HorizontalAlignment','left');
            handles.h_point_hata = uicontrol(pnl_point, 'Style', 'edit', 'String', '0.5', 'Position', [140, 130, 100, 22]);
            uicontrol(pnl_point, 'Style', 'pushbutton', 'String', 'Hesapla ve Ekle', 'Position', [70, 90, 140, 30], 'BackgroundColor', renkler.buton_aksiyon, 'ForegroundColor', 'w', 'Callback', @hesapla_point_callback);
            uicontrol(pnl_point, 'Style', 'text', 'String', 'Loss (dB) = 12 * (hata / hüzme_genişliği)^2', 'Position', [10, 55, 260, 20], 'BackgroundColor', renkler.panel_turuncu);
            uicontrol(pnl_point, 'Style', 'text', 'String', 'Sonuç (dB):', 'FontWeight', 'bold', 'Position', [10, 20, 120, 20], 'BackgroundColor', renkler.panel_turuncu);
            handles.h_point_sonuc = uicontrol(pnl_point, 'Style', 'text', 'String', '', 'Position', [140, 20, 100, 20], 'FontWeight', 'bold', 'ForegroundColor', renkler.baslik);
        pnl_rain = uipanel(ic_tab_kayip, 'Title', 'Yağmur Zayıflaması', 'Position', [x1, y2, pnl_W, pnl_H], 'BackgroundColor', renkler.panel_kirmizi);
            y_pos = 190; dy = 30;
            uicontrol(pnl_rain, 'Style', 'text', 'String', 'Frekans (GHz):', 'Position', [10, y_pos, 120, 20], 'BackgroundColor', renkler.panel_kirmizi, 'HorizontalAlignment','left');
            handles.h_rain_frekans = uicontrol(pnl_rain, 'Style', 'edit', 'String', num2str(uyduVerileri.verici.frekans), 'Position', [140, y_pos, 100, 22]); y_pos=y_pos-dy;
            uicontrol(pnl_rain, 'Style', 'text', 'String', 'Rain Rate (mm/saat):', 'Position', [10, y_pos, 120, 20], 'BackgroundColor', renkler.panel_kirmizi, 'HorizontalAlignment','left');
            handles.h_rain_yagmur = uicontrol(pnl_rain, 'Style', 'edit', 'String', '20', 'Position', [140, y_pos, 100, 22]); y_pos=y_pos-dy;
            uicontrol(pnl_rain, 'Style', 'text', 'String', 'Path Length (km):', 'Position', [10, y_pos, 120, 20], 'BackgroundColor', renkler.panel_kirmizi, 'HorizontalAlignment','left');
            handles.h_rain_yol = uicontrol(pnl_rain, 'Style', 'edit', 'String', '1', 'Position', [140, y_pos, 100, 22]); y_pos=y_pos-dy;
            uicontrol(pnl_rain, 'Style', 'text', 'String', 'Elevation Angle (derece):', 'Position', [10, y_pos, 120, 20], 'BackgroundColor', renkler.panel_kirmizi, 'HorizontalAlignment','left');
            handles.h_rain_elev = uicontrol(pnl_rain, 'Style', 'edit', 'String', '45', 'Position', [140, y_pos, 100, 22]); y_pos=y_pos-dy;
            uicontrol(pnl_rain, 'Style', 'pushbutton', 'String', 'Hesapla ve Ekle', 'Position', [70, 20, 140, 30], 'BackgroundColor', renkler.buton_aksiyon, 'ForegroundColor', 'w', 'Callback', @hesapla_rain_callback);
            uicontrol(pnl_rain, 'Style', 'text', 'String', 'Sonuç (dB):', 'FontWeight', 'bold', 'Position', [10, 55, 120, 20], 'BackgroundColor', renkler.panel_kirmizi);
            handles.h_rain_sonuc = uicontrol(pnl_rain, 'Style', 'text', 'String', '', 'Position', [140, 55, 100, 20], 'FontWeight', 'bold', 'ForegroundColor', renkler.baslik);
        pnl_gas = uipanel(ic_tab_kayip, 'Title', 'Gaz Soğurması', 'Position', [x2, y2, pnl_W, pnl_H], 'BackgroundColor', renkler.panel_yesil_koyu);
            y_pos = 190; dy = 30;
            uicontrol(pnl_gas, 'Style', 'text', 'String', 'Temperature (C):', 'Position', [10, y_pos, 120, 20], 'BackgroundColor', renkler.panel_yesil_koyu, 'HorizontalAlignment','left');
            handles.h_gas_temp = uicontrol(pnl_gas, 'Style', 'edit', 'String', '15', 'Position', [140, y_pos, 100, 22]); y_pos=y_pos-dy;
            uicontrol(pnl_gas, 'Style', 'text', 'String', 'Frekans (GHz):', 'Position', [10, y_pos, 120, 20], 'BackgroundColor', renkler.panel_yesil_koyu, 'HorizontalAlignment','left');
            handles.h_gas_freq = uicontrol(pnl_gas, 'Style', 'edit', 'String', num2str(uyduVerileri.verici.frekans), 'Position', [140, y_pos, 100, 22]); y_pos=y_pos-dy;
            uicontrol(pnl_gas, 'Style', 'text', 'String', 'Path Length (km):', 'Position', [10, y_pos, 120, 20], 'BackgroundColor', renkler.panel_yesil_koyu, 'HorizontalAlignment','left');
            handles.h_gas_path = uicontrol(pnl_gas, 'Style', 'edit', 'String', '4', 'Position', [140, y_pos, 100, 22]); y_pos=y_pos-dy;
            uicontrol(pnl_gas, 'Style', 'text', 'String', 'Pressure (hPa):', 'Position', [10, y_pos, 120, 20], 'BackgroundColor', renkler.panel_yesil_koyu, 'HorizontalAlignment','left');
            handles.h_gas_press = uicontrol(pnl_gas, 'Style', 'edit', 'String', '1013', 'Position', [140, y_pos, 100, 22]); y_pos=y_pos-dy;
            uicontrol(pnl_gas, 'Style', 'text', 'String', 'Water V. Density (g/m³):', 'Position', [10, y_pos, 120, 20], 'BackgroundColor', renkler.panel_yesil_koyu, 'HorizontalAlignment','left');
            handles.h_gas_density = uicontrol(pnl_gas, 'Style', 'edit', 'String', '7.5', 'Position', [140, y_pos, 100, 22]);
            uicontrol(pnl_gas, 'Style', 'pushbutton', 'String', 'Hesapla ve Ekle', 'Position', [70, 0, 140, 30], 'BackgroundColor', renkler.buton_aksiyon, 'ForegroundColor', 'w', 'Callback', @hesapla_gas_callback);
            uicontrol(pnl_gas, 'Style', 'text', 'String', 'Sonuç (dB):', 'FontWeight', 'bold', 'Position', [10, 30, 120, 20], 'BackgroundColor', renkler.panel_yesil_koyu);
            handles.h_gas_sonuc = uicontrol(pnl_gas, 'Style', 'text', 'String', '', 'Position', [140, 30, 100, 20], 'FontWeight', 'bold', 'ForegroundColor', renkler.baslik);
            
    ic_tab_anten = uitab(handles.ic_tab_grubu, 'Title', 'Anten Hesaplayıcıları', 'BackgroundColor', renkler.tab2);
        pnl_antgain = uipanel(ic_tab_anten, 'Title', 'Anten Kazancı', 'Position', [x1, y1, pnl_W, pnl_H], 'BackgroundColor', renkler.panel_mavi_koyu);
            uicontrol(pnl_antgain, 'Style', 'text', 'String', 'Frekans (GHz):', 'Position', [10, 190, 120, 20], 'BackgroundColor', renkler.panel_mavi_koyu, 'HorizontalAlignment', 'left');
            handles.h_antgain_freq = uicontrol(pnl_antgain, 'Style', 'edit', 'String', num2str(uyduVerileri.verici.frekans), 'Position', [140, 190, 100, 22]);
            uicontrol(pnl_antgain, 'Style', 'text', 'String', 'Anten Çapı (m):', 'Position', [10, 160, 120, 20], 'BackgroundColor', renkler.panel_mavi_koyu, 'HorizontalAlignment', 'left');
            handles.h_antgain_cap = uicontrol(pnl_antgain, 'Style', 'edit', 'String', num2str(uyduVerileri.alici.capR), 'Position', [140, 160, 100, 22]);
            uicontrol(pnl_antgain, 'Style', 'text', 'String', 'Verimlilik (0-1):', 'Position', [10, 130, 120, 20], 'BackgroundColor', renkler.panel_mavi_koyu, 'HorizontalAlignment', 'left');
            handles.h_antgain_verim = uicontrol(pnl_antgain, 'Style', 'edit', 'String', '0.6', 'Position', [140, 130, 100, 22]);
            uicontrol(pnl_antgain, 'Style', 'pushbutton', 'String', 'Hesapla', 'Position', [70, 90, 140, 30], 'BackgroundColor', renkler.buton_aksiyon, 'ForegroundColor', 'w', 'Callback', @hesapla_antgain_callback);
            uicontrol(pnl_antgain, 'Style', 'text', 'String', 'G = 10*log10(η * (π*D/λ)^2)', 'Position', [10, 55, 260, 20], 'BackgroundColor', renkler.panel_mavi_koyu);
            uicontrol(pnl_antgain, 'Style', 'text', 'String', 'Kazanç (dBi):', 'FontWeight', 'bold', 'Position', [10, 20, 120, 20], 'BackgroundColor', renkler.panel_mavi_koyu);
            handles.h_antgain_sonuc = uicontrol(pnl_antgain, 'Style', 'text', 'String', '', 'Position', [140, 20, 100, 20], 'FontWeight', 'bold', 'ForegroundColor', renkler.baslik);
        pnl_bw = uipanel(ic_tab_anten, 'Title', 'Hüzme Genişliği', 'Position', [x2, y1, pnl_W, pnl_H], 'BackgroundColor', renkler.panel_mor);
            uicontrol(pnl_bw, 'Style', 'text', 'String', 'Anten Çapı (m):', 'Position', [10, 190, 120, 20], 'BackgroundColor', renkler.panel_mor, 'HorizontalAlignment','left');
            handles.h_bw_d = uicontrol(pnl_bw, 'Style', 'edit', 'String', num2str(uyduVerileri.alici.capR), 'Position', [140, 190, 100, 22]);
            uicontrol(pnl_bw, 'Style', 'text', 'String', 'Frekans (GHz):', 'Position', [10, 160, 120, 20], 'BackgroundColor', renkler.panel_mor, 'HorizontalAlignment','left');
            handles.h_bw_f = uicontrol(pnl_bw, 'Style', 'edit', 'String', num2str(uyduVerileri.verici.frekans), 'Position', [140, 160, 100, 22]);
            uicontrol(pnl_bw, 'Style', 'pushbutton', 'String', 'Hesapla', 'Position', [70, 120, 140, 30], 'BackgroundColor', renkler.buton_aksiyon, 'ForegroundColor', 'w', 'Callback', @hesapla_bw_callback);
            uicontrol(pnl_bw, 'Style', 'text', 'String', 'Formül: BW (deg) ≈ 70 * (λ / D)', 'Position', [10, 80, 260, 20], 'BackgroundColor', renkler.panel_mor);
            uicontrol(pnl_bw, 'Style', 'text', 'String', 'Hüzme Genişliği (deg):', 'FontWeight', 'bold', 'Position', [10, 40, 120, 20], 'BackgroundColor', renkler.panel_mor, 'HorizontalAlignment','left');
            handles.h_bw_sonuc = uicontrol(pnl_bw, 'Style', 'text', 'String', '', 'Position', [140, 40, 100, 20], 'FontWeight', 'bold', 'ForegroundColor', renkler.baslik);
        pnl_gt = uipanel(ic_tab_anten, 'Title', 'G/T Hesaplayıcı', 'Position', [x3, y1, pnl_W, pnl_H], 'BackgroundColor', renkler.panel_turuncu);
            uicontrol(pnl_gt, 'Style', 'text', 'String', 'Anten Kazancı (dBi):', 'Position', [10, 190, 120, 20], 'BackgroundColor', renkler.panel_turuncu, 'HorizontalAlignment','left');
            handles.h_gt_g = uicontrol(pnl_gt, 'Style', 'edit', 'String', '...', 'Position', [140, 190, 100, 22]);
            uicontrol(pnl_gt, 'Style', 'text', 'String', 'Sistem Gürültü Sıck. (K):', 'Position', [10, 160, 120, 20], 'BackgroundColor', renkler.panel_turuncu, 'HorizontalAlignment','left');
            handles.h_gt_t = uicontrol(pnl_gt, 'Style', 'edit', 'String', num2str(uyduVerileri.alici.sicaklik), 'Position', [140, 160, 100, 22]);
            uicontrol(pnl_gt, 'Style', 'pushbutton', 'String', 'Hesapla', 'Position', [70, 120, 140, 30], 'BackgroundColor', renkler.buton_aksiyon, 'ForegroundColor', 'w', 'Callback', @hesapla_gt_callback);
            uicontrol(pnl_gt, 'Style', 'text', 'String', 'G/T (dB/K) = G (dBi) - 10*log10(T)', 'Position', [10, 80, 260, 20], 'BackgroundColor', renkler.panel_turuncu);
            uicontrol(pnl_gt, 'Style', 'text', 'String', 'G/T (dB/K):', 'FontWeight', 'bold', 'Position', [10, 40, 120, 20], 'BackgroundColor', renkler.panel_turuncu, 'HorizontalAlignment','left');
            handles.h_gt_sonuc = uicontrol(pnl_gt, 'Style', 'text', 'String', '', 'Position', [140, 40, 100, 20], 'FontWeight', 'bold', 'ForegroundColor', renkler.baslik);
        pnl_antnoise = uipanel(ic_tab_anten, 'Title', 'Anten Gürültü Sıcaklığı', 'Position', [x1, y2, pnl_W, pnl_H], 'BackgroundColor', renkler.panel_kirmizi);
            uicontrol(pnl_antnoise, 'Style', 'text', 'String', 'Gök Gürültüsü (T_sky) (K):', 'Position', [10, 190, 120, 20], 'BackgroundColor', renkler.panel_kirmizi, 'HorizontalAlignment', 'left');
            handles.h_antnoise_tsky = uicontrol(pnl_antnoise, 'Style', 'edit', 'String', '50', 'Position', [140, 190, 100, 22]);
            uicontrol(pnl_antnoise, 'Style', 'text', 'String', 'Anten Fiziksel Sıck. (T_p) (K):', 'Position', [10, 160, 120, 20], 'BackgroundColor', renkler.panel_kirmizi, 'HorizontalAlignment', 'left');
            handles.h_antnoise_tp = uicontrol(pnl_antnoise, 'Style', 'edit', 'String', '290', 'Position', [140, 160, 100, 22]);
            uicontrol(pnl_antnoise, 'Style', 'text', 'String', 'Anten Verimliliği (eta) (0-1):', 'Position', [10, 130, 120, 20], 'BackgroundColor', renkler.panel_kirmizi, 'HorizontalAlignment', 'left');
            handles.h_antnoise_eta = uicontrol(pnl_antnoise, 'Style', 'edit', 'String', '0.6', 'Position', [140, 130, 100, 22]);
            uicontrol(pnl_antnoise, 'Style', 'pushbutton', 'String', 'Hesapla', 'Position', [70, 90, 140, 30], 'BackgroundColor', renkler.buton_aksiyon, 'ForegroundColor', 'w', 'Callback', @hesapla_antnoise_callback);
            uicontrol(pnl_antnoise, 'Style', 'text', 'String', 'T_a = (η * T_sky) + (1-η) * T_p', 'Position', [10, 55, 260, 20], 'BackgroundColor', renkler.panel_kirmizi);
            uicontrol(pnl_antnoise, 'Style', 'text', 'String', 'Anten Sıcaklığı (T_a) (K):', 'FontWeight', 'bold', 'Position', [10, 20, 120, 20], 'BackgroundColor', renkler.panel_kirmizi, 'HorizontalAlignment','left');
            handles.h_antnoise_sonuc = uicontrol(pnl_antnoise, 'Style', 'text', 'String', '', 'Position', [140, 20, 100, 20], 'FontWeight', 'bold', 'ForegroundColor', renkler.baslik);
        pnl_focal = uipanel(ic_tab_anten, 'Title', 'Odak Mesafesi', 'Position', [x2, y2, pnl_W, pnl_H], 'BackgroundColor', renkler.panel_yesil_koyu);
            uicontrol(pnl_focal, 'Style', 'text', 'String', 'Anten Çapı (D) (m):', 'Position', [10, 190, 120, 20], 'BackgroundColor', renkler.panel_yesil_koyu, 'HorizontalAlignment','left');
            handles.h_focal_d = uicontrol(pnl_focal, 'Style', 'edit', 'String', num2str(uyduVerileri.alici.capR), 'Position', [140, 190, 100, 22]);
            uicontrol(pnl_focal, 'Style', 'text', 'String', 'Anten Derinliği (d) (m):', 'Position', [10, 160, 120, 20], 'BackgroundColor', renkler.panel_yesil_koyu, 'HorizontalAlignment','left');
            handles.h_focal_depth = uicontrol(pnl_focal, 'Style', 'edit', 'String', '0.1', 'Position', [140, 160, 100, 22]);
            uicontrol(pnl_focal, 'Style', 'pushbutton', 'String', 'Hesapla', 'Position', [70, 120, 140, 30], 'BackgroundColor', renkler.buton_aksiyon, 'ForegroundColor', 'w', 'Callback', @hesapla_focal_callback);
            uicontrol(pnl_focal, 'Style', 'text', 'String', 'Formül: f = D² / (16 * d)', 'Position', [10, 80, 260, 20], 'BackgroundColor', renkler.panel_yesil_koyu);
            uicontrol(pnl_focal, 'Style', 'text', 'String', 'Odak Mesafesi (f) (m):', 'FontWeight', 'bold', 'Position', [10, 40, 120, 20], 'BackgroundColor', renkler.panel_yesil_koyu, 'HorizontalAlignment','left');
            handles.h_focal_sonuc = uicontrol(pnl_focal, 'Style', 'text', 'String', '', 'Position', [140, 40, 100, 20], 'FontWeight', 'bold', 'ForegroundColor', renkler.baslik);
            
    ic_tab_araclar = uitab(handles.ic_tab_grubu, 'Title', 'Yardımcı Dönüştürücüler', 'BackgroundColor', renkler.tab2);
        pnl_power = uipanel(ic_tab_araclar, 'Title', 'Güç Oranı (W, dBm, dBW)', 'Position', [x1, y1, pnl_W, pnl_H], 'BackgroundColor', renkler.panel_mavi_koyu);
            uicontrol(pnl_power, 'Style', 'text', 'String', 'Power (W):', 'Position', [10, 190, 120, 20], 'BackgroundColor', renkler.panel_mavi_koyu, 'HorizontalAlignment','left');
            handles.h_power_w = uicontrol(pnl_power, 'Style', 'edit', 'String', '1', 'Position', [140, 190, 100, 22]);
            uicontrol(pnl_power, 'Style', 'text', 'String', 'Power (dBm):', 'Position', [10, 160, 120, 20], 'BackgroundColor', renkler.panel_mavi_koyu, 'HorizontalAlignment','left');
            handles.h_power_dbm = uicontrol(pnl_power, 'Style', 'edit', 'String', '', 'Position', [140, 160, 100, 22]);
            uicontrol(pnl_power, 'Style', 'text', 'String', 'Power (dBW):', 'Position', [10, 130, 120, 20], 'BackgroundColor', renkler.panel_mavi_koyu, 'HorizontalAlignment','left');
            handles.h_power_dbw = uicontrol(pnl_power, 'Style', 'edit', 'String', '', 'Position', [140, 130, 100, 22]);
            uicontrol(pnl_power, 'Style', 'pushbutton', 'String', 'Hesapla / Çevir', 'Position', [70, 70, 140, 40], 'BackgroundColor', renkler.buton_aksiyon, 'ForegroundColor', 'w', 'Callback', @hesapla_power_callback);
        pnl_freq = uipanel(ic_tab_araclar, 'Title', 'Frekans (Hz, MHz, GHz)', 'Position', [x2, y1, pnl_W, pnl_H], 'BackgroundColor', renkler.panel_mor);
            uicontrol(pnl_freq, 'Style', 'text', 'String', 'Frequency (MHz):', 'Position', [10, 190, 120, 20], 'BackgroundColor', renkler.panel_mor, 'HorizontalAlignment','left');
            handles.h_freq_mhz = uicontrol(pnl_freq, 'Style', 'edit', 'String', '433', 'Position', [140, 190, 100, 22]);
            uicontrol(pnl_freq, 'Style', 'text', 'String', 'Frequency (GHz):', 'Position', [10, 160, 120, 20], 'BackgroundColor', renkler.panel_mor, 'HorizontalAlignment','left');
            handles.h_freq_ghz = uicontrol(pnl_freq, 'Style', 'edit', 'String', '', 'Position', [140, 160, 100, 22]);
            uicontrol(pnl_freq, 'Style', 'text', 'String', 'Frequency (Hz):', 'Position', [10, 130, 120, 20], 'BackgroundColor', renkler.panel_mor, 'HorizontalAlignment','left');
            handles.h_freq_hz = uicontrol(pnl_freq, 'Style', 'edit', 'String', '', 'Position', [140, 130, 100, 22]);
            uicontrol(pnl_freq, 'Style', 'pushbutton', 'String', 'Hesapla / Çevir', 'Position', [70, 70, 140, 40], 'BackgroundColor', renkler.buton_aksiyon, 'ForegroundColor', 'w', 'Callback', @hesapla_freq_callback);
        pnl_ntemp = uipanel(ic_tab_araclar, 'Title', 'Gürültü (NF -> T)', 'Position', [x3, y1, pnl_W, pnl_H], 'BackgroundColor', renkler.panel_turuncu);
            uicontrol(pnl_ntemp, 'Style', 'text', 'String', 'Noise Figure (NF) (dB):', 'Position', [10, 190, 120, 20], 'BackgroundColor', renkler.panel_turuncu, 'HorizontalAlignment','left');
            handles.h_ntemp_nf = uicontrol(pnl_ntemp, 'Style', 'edit', 'String', '3', 'Position', [140, 190, 100, 22]);
            uicontrol(pnl_ntemp, 'Style', 'text', 'String', 'Noise Factor (F):', 'Position', [10, 160, 120, 20], 'BackgroundColor', renkler.panel_turuncu, 'HorizontalAlignment','left');
            handles.h_ntemp_f = uicontrol(pnl_ntemp, 'Style', 'edit', 'String', '', 'Position', [140, 160, 100, 22]);
            uicontrol(pnl_ntemp, 'Style', 'text', 'String', 'Noise Temperature (K):', 'Position', [10, 130, 120, 20], 'BackgroundColor', renkler.panel_turuncu, 'HorizontalAlignment','left');
            handles.h_ntemp_t = uicontrol(pnl_ntemp, 'Style', 'edit', 'String', '', 'Position', [140, 130, 100, 22]);
            uicontrol(pnl_ntemp, 'Style', 'pushbutton', 'String', 'Hesapla / Çevir', 'Position', [70, 70, 140, 40], 'BackgroundColor', renkler.buton_aksiyon, 'ForegroundColor', 'w', 'Callback', @hesapla_ntemp_callback);
        pnl_nf = uipanel(ic_tab_araclar, 'Title', 'Gürültü (T -> NF)', 'Position', [x1, y2, pnl_W, pnl_H], 'BackgroundColor', renkler.panel_kirmizi);
            uicontrol(pnl_nf, 'Style', 'text', 'String', 'Noise Temperature (K):', 'Position', [10, 190, 120, 20], 'BackgroundColor', renkler.panel_kirmizi, 'HorizontalAlignment','left');
            handles.h_nf_t = uicontrol(pnl_nf, 'Style', 'edit', 'String', '290', 'Position', [140, 190, 100, 22]);
            uicontrol(pnl_nf, 'Style', 'text', 'String', 'Noise Factor (F):', 'Position', [10, 160, 120, 20], 'BackgroundColor', renkler.panel_kirmizi, 'HorizontalAlignment','left');
            handles.h_nf_f = uicontrol(pnl_nf, 'Style', 'edit', 'String', '', 'Position', [140, 160, 100, 22]);
            uicontrol(pnl_nf, 'Style', 'text', 'String', 'Noise Figure (NF) (dB):', 'Position', [10, 130, 120, 20], 'BackgroundColor', renkler.panel_kirmizi, 'HorizontalAlignment','left');
            handles.h_nf_nf = uicontrol(pnl_nf, 'Style', 'edit', 'String', '', 'Position', [140, 130, 100, 22]);
            uicontrol(pnl_nf, 'Style', 'pushbutton', 'String', 'Hesapla / Çevir', 'Position', [70, 70, 140, 40], 'BackgroundColor', renkler.buton_aksiyon, 'ForegroundColor', 'w', 'Callback', @hesapla_nf_callback);
        pnl_wave = uipanel(ic_tab_araclar, 'Title', 'Dalga Boyu (f -> λ)', 'Position', [x2, y2, pnl_W, pnl_H], 'BackgroundColor', renkler.panel_yesil_koyu);
            uicontrol(pnl_wave, 'Style', 'text', 'String', 'Frekans (MHz):', 'Position', [10, 190, 120, 20], 'BackgroundColor', renkler.panel_yesil_koyu);
            handles.h_wave_freq = uicontrol(pnl_wave, 'Style', 'edit', 'String', '433', 'Position', [140, 190, 100, 22]);
            uicontrol(pnl_wave, 'Style', 'pushbutton', 'String', 'Hesapla', 'Position', [70, 120, 140, 30], 'BackgroundColor', renkler.buton_aksiyon, 'ForegroundColor', 'w', 'Callback', @hesapla_wave_callback);
            uicontrol(pnl_wave, 'Style', 'text', 'String', 'Formül: λ = 300 / f (MHz)', 'Position', [10, 80, 260, 20], 'BackgroundColor', renkler.panel_yesil_koyu);
            uicontrol(pnl_wave, 'Style', 'text', 'String', 'Dalga Boyu (m):', 'FontWeight', 'bold', 'Position', [10, 40, 120, 20], 'BackgroundColor', renkler.panel_yesil_koyu);
            handles.h_wave_sonuc = uicontrol(pnl_wave, 'Style', 'text', 'String', '', 'Position', [140, 40, 100, 20], 'FontWeight', 'bold', 'ForegroundColor', renkler.baslik);
        pnl_path = uipanel(ic_tab_araclar, 'Title', 'Yol Uzunluğu (Düz Dünya)', 'Position', [x3, y2, pnl_W, pnl_H], 'BackgroundColor', renkler.panel_mavi_koyu);
            uicontrol(pnl_path, 'Style', 'text', 'String', 'Uydu İrtifası (km):', 'Position', [10, 190, 120, 20], 'BackgroundColor', renkler.panel_mavi_koyu, 'HorizontalAlignment','left');
            handles.h_path_h = uicontrol(pnl_path, 'Style', 'edit', 'String', '600', 'Position', [140, 190, 100, 22]);
            uicontrol(pnl_path, 'Style', 'text', 'String', 'Yükseliş Açısı (deg):', 'Position', [10, 160, 120, 20], 'BackgroundColor', renkler.panel_mavi_koyu, 'HorizontalAlignment','left');
            handles.h_path_el = uicontrol(pnl_path, 'Style', 'edit', 'String', '45', 'Position', [140, 160, 100, 22]);
            uicontrol(pnl_path, 'Style', 'pushbutton', 'String', 'Hesapla', 'Position', [70, 120, 140, 30], 'BackgroundColor', renkler.buton_aksiyon, 'ForegroundColor', 'w', 'Callback', @hesapla_path_callback);
            uicontrol(pnl_path, 'Style', 'text', 'String', 'Formül: L = H / sind(El)', 'Position', [10, 80, 260, 20], 'BackgroundColor', renkler.panel_mavi_koyu);
            uicontrol(pnl_path, 'Style', 'text', 'String', 'Yol Uzunluğu (km):', 'FontWeight', 'bold', 'Position', [10, 40, 120, 20], 'BackgroundColor', renkler.panel_mavi_koyu, 'HorizontalAlignment','left');
            handles.h_path_sonuc = uicontrol(pnl_path, 'Style', 'text', 'String', '', 'Position', [140, 40, 100, 20], 'FontWeight', 'bold', 'ForegroundColor', renkler.baslik);
            
    ic_tab_kayip_grafik = uitab(handles.ic_tab_grubu, 'Title', 'Kayıp Dökümü', 'BackgroundColor', renkler.tab2);
        handles.loss_axes = axes('Parent', ic_tab_kayip_grafik, 'Position', [0.1, 0.1, 0.8, 0.8]);
        title(handles.loss_axes, 'Kayıp dökümünü görmek için ana "Hesapla" butonuna basın');
        grid(handles.loss_axes, 'on');
    
    ic_tab_grafik = uitab(handles.ic_tab_grubu, 'Title', 'Link Analiz Grafikleri', 'BackgroundColor', renkler.tab2);
    pnl_fsl_grafik = uipanel(ic_tab_grafik, 'Title', 'FSL vs. Mesafe (dB vs. km)', 'FontWeight', 'bold', 'Position', [0.02, 0.02, 0.47, 0.96], 'BackgroundColor', renkler.tab2);
    handles.fsl_axes = axes('Parent', pnl_fsl_grafik, 'Position', [0.15, 0.1, 0.8, 0.85]);
    title(handles.fsl_axes, 'FSL (dB) vs. Mesafe (km)');
    xlabel(handles.fsl_axes, 'Mesafe (km)');
    ylabel(handles.fsl_axes, 'FSL (dB)');
    grid(handles.fsl_axes, 'on');
    
    pnl_kontur_grafik_tab = uipanel(ic_tab_grafik, 'Title', 'Link Marjı Kontur (Tx Gücü vs. Mesafe)', 'FontWeight', 'bold', 'Position', [0.51, 0.02, 0.47, 0.96], 'BackgroundColor', renkler.tab2);
    handles.kontur_axes = axes('Parent', pnl_kontur_grafik_tab, 'Position', [0.1, 0.1, 0.8, 0.85]);
    title(handles.kontur_axes, 'Kontur Grafiği Oluşturulmadı');
    xlabel(handles.kontur_axes, 'Tx HPA Gücü (dBW)');
    ylabel(handles.kontur_axes, 'Mesafe (km)');
    grid(handles.kontur_axes, 'on');
    
    % --- TAB 3 ---
    handles.tab_sim = uitab(handles.ana_tab_grubu, 'Title', '3. Simülasyon & Optimizasyon', 'BackgroundColor', renkler.tab3);
    handles.sim_tab_grubu = uitabgroup(handles.tab_sim, 'Position', [0.01, 0.01, 0.98, 0.98]);
    handles.sim_tab_ana = uitab(handles.sim_tab_grubu, 'Title', 'Simülasyon & Raporlama', 'BackgroundColor', renkler.tab3);
        pnl_sim_girdi = uipanel(handles.sim_tab_ana, 'Title', 'Uçuş Simülasyonu Girdileri', 'FontWeight', 'bold', 'Position', [0.02, 0.75, 0.45, 0.22], 'BackgroundColor', renkler.tab3);
            uicontrol(pnl_sim_girdi, 'Style','text', 'String','Maksimum İrtifa (metre):', 'Position',[10,80,150,20], 'BackgroundColor',renkler.tab3, 'HorizontalAlignment','left');
            handles.h_sim_irtifa = uicontrol(pnl_sim_girdi, 'Style','edit','String','4000', 'Position',[170,80,150,22]);
            uicontrol(pnl_sim_girdi, 'Style','text', 'String','Alçalma Hızı (m/s):', 'Position',[10,40,150,20], 'BackgroundColor',renkler.tab3, 'HorizontalAlignment','left');
            handles.h_sim_hiz = uicontrol(pnl_sim_girdi, 'Style','edit','String','15', 'Position',[170,40,150,22]);
            uicontrol(pnl_sim_girdi, 'Style','pushbutton','String','Simülasyonu Başlat', 'Position',[330,40,100,62], 'BackgroundColor',renkler.buton_ana, 'ForegroundColor','w', 'Callback',@simulasyonu_calistir_callback);
        pnl_raporlama = uipanel(handles.sim_tab_ana, 'Title', 'Raporlama ve Araçlar', 'FontWeight', 'bold', 'Position', [0.5, 0.75, 0.48, 0.22], 'BackgroundColor', renkler.tab3);
            uicontrol(pnl_raporlama, 'Style', 'pushbutton', 'String', 'Rapor Oluştur', 'FontSize', 10, 'Position', [50, 40, 150, 60], 'BackgroundColor', renkler.buton_ana, 'Callback', @rapor_olustur_ac);
            uicontrol(pnl_raporlama, 'Style', 'pushbutton', 'String', 'Formül Listesi', 'FontSize', 10, 'Position', [250, 40, 150, 40], 'BackgroundColor', renkler.buton_ana, 'Callback', @formulleri_goster_ac);
        
        pnl_sim_grafik = uipanel(handles.sim_tab_ana, 'Title', 'Simülasyon Grafiği (Link Marjı vs. Zaman)', 'FontWeight', 'bold', 'Position', [0.02, 0.03, 0.45, 0.68], 'BackgroundColor', renkler.tab3);
            handles.sim_axes = axes('Parent', pnl_sim_grafik, 'Position', [0.1, 0.1, 0.85, 0.8]);
            title(handles.sim_axes, 'Simülasyonu başlatın');
            grid(handles.sim_axes, 'on'); box(handles.sim_axes, 'on');
            
        pnl_sonuclar = uipanel(handles.sim_tab_ana, 'Title', 'Genel Sonuçlar (Maks. İrtifada)', 'FontWeight', 'bold', 'Position', [0.5, 0.03, 0.48, 0.68], 'BackgroundColor', renkler.tab3); 
            handles.sonuc_listbox = uicontrol('Parent', pnl_sonuclar, 'Style', 'listbox', 'String', {'Hesaplama yapılmadı.'}, ...
                                              'Position', [10, 10, 440, 340], 'FontSize', 10, 'FontName', 'Courier New');
    
    handles.sim_tab_opt = uitab(handles.sim_tab_grubu, 'Title', 'Gelişmiş Optimizasyon', 'BackgroundColor', renkler.tab_opt);
        pnl_optimizasyon = uipanel(handles.sim_tab_opt, 'Title', 'Çok Amaçlı Tasarım Optimizasyonu (GA)', 'FontWeight', 'bold', 'Position', [0.02, 0.02, 0.96, 0.96], 'BackgroundColor', renkler.tab_opt);
        uicontrol(pnl_optimizasyon, 'Style','text','String','Değişken','Position',[20, 480, 100, 20],'BackgroundColor',renkler.tab_opt,'FontWeight','bold', 'HorizontalAlignment','left');
        uicontrol(pnl_optimizasyon, 'Style','text','String','Aktif?','Position',[130, 480, 50, 20],'BackgroundColor',renkler.tab_opt,'FontWeight','bold');
        uicontrol(pnl_optimizasyon, 'Style','text','String','Ağırlık (Önem)','Position',[200, 480, 100, 20],'BackgroundColor',renkler.tab_opt,'FontWeight','bold');
        uicontrol(pnl_optimizasyon, 'Style','text','String','Min. Değer','Position',[320, 480, 100, 20],'BackgroundColor',renkler.tab_opt,'FontWeight','bold');
        uicontrol(pnl_optimizasyon, 'Style','text','String','Maks. Değer','Position',[440, 480, 100, 20],'BackgroundColor',renkler.tab_opt,'FontWeight','bold');
        y_pos = 440; 
        uicontrol(pnl_optimizasyon, 'Style','text','String','Verici Gücü (W)','Position',[20, y_pos, 100, 20],'BackgroundColor',renkler.tab_opt, 'HorizontalAlignment','left');
        handles.h_opt_cb_guc = uicontrol(pnl_optimizasyon, 'Style','checkbox','Value',1,'Position',[145, y_pos, 20, 20],'BackgroundColor',renkler.tab_opt);
        handles.h_opt_w_guc  = uicontrol(pnl_optimizasyon, 'Style','edit','String','2.0','Position',[200, y_pos, 100, 22]);
        handles.h_opt_lb_guc = uicontrol(pnl_optimizasyon, 'Style','edit','String','0.05','Position',[320, y_pos, 100, 22]);
        handles.h_opt_ub_guc = uicontrol(pnl_optimizasyon, 'Style','edit','String','1.0','Position',[440, y_pos, 100, 22]);
        y_pos = 400; 
        uicontrol(pnl_optimizasyon, 'Style','text','String','Verici Çapı (m)','Position',[20, y_pos, 100, 20],'BackgroundColor',renkler.tab_opt, 'HorizontalAlignment','left');
        handles.h_opt_cb_capT = uicontrol(pnl_optimizasyon, 'Style','checkbox','Value',0,'Position',[145, y_pos, 20, 20],'BackgroundColor',renkler.tab_opt);
        handles.h_opt_w_capT  = uicontrol(pnl_optimizasyon, 'Style','edit','String','1.0','Position',[200, y_pos, 100, 22]);
        handles.h_opt_lb_capT = uicontrol(pnl_optimizasyon, 'Style','edit','String','0.1','Position',[320, y_pos, 100, 22]);
        handles.h_opt_ub_capT = uicontrol(pnl_optimizasyon, 'Style', 'edit', 'String', '0.5', 'Position', [440, y_pos, 100, 22]);
        y_pos = 360; 
        uicontrol(pnl_optimizasyon, 'Style','text','String','Alıcı Çapı (m)','Position',[20, y_pos, 100, 20],'BackgroundColor',renkler.tab_opt, 'HorizontalAlignment','left');
        handles.h_opt_cb_capR = uicontrol(pnl_optimizasyon, 'Style','checkbox','Value',1,'Position',[145, y_pos, 20, 20],'BackgroundColor',renkler.tab_opt);
        handles.h_opt_w_capR  = uicontrol(pnl_optimizasyon, 'Style','edit','String','1.0','Position',[200, y_pos, 100, 22]);
        handles.h_opt_lb_capR = uicontrol(pnl_optimizasyon, 'Style','edit','String','0.3','Position', [320, y_pos, 100, 22]);
        handles.h_opt_ub_capR = uicontrol(pnl_optimizasyon, 'Style','edit','String','3.0','Position',[440, y_pos, 100, 22]);
        uipanel(pnl_optimizasyon, 'Position', [40, 330, 800, 2], 'BackgroundColor', renkler.baslik);
        uicontrol(pnl_optimizasyon, 'Style','text','String','Hedef Link Marjı (Kısıt):','Position',[20, 250, 280, 20],'BackgroundColor',renkler.tab_opt, 'HorizontalAlignment','left', 'FontSize', 11, 'FontWeight','bold');
        handles.h_opt_hedef_marj = uicontrol(pnl_optimizasyon, 'Style','edit','String','3.0','Position',[320, 250, 100, 25], 'FontSize', 11, 'FontWeight','bold');
        uicontrol(pnl_optimizasyon, 'Style','text','String','dB','Position',[425, 250, 20, 20],'BackgroundColor',renkler.tab_opt, 'HorizontalAlignment','left', 'FontSize', 11);
        uicontrol(pnl_optimizasyon, 'Style','pushbutton','String','GELİŞMİŞ OPTİMİZASYONU BAŞLAT (GA)', 'Position',[200, 100, 500, 60], 'BackgroundColor',[0.2, 0.6, 0.2], 'ForegroundColor','w', 'FontSize', 14, 'FontWeight','bold', 'Callback',@optimize_et_callback);
        aciklama_metni = { 'Açıklama:', '1. Optimize etmek istediğiniz değişkenleri "Aktif?" kutusundan seçin.', '2. Her değişkenin "Ağırlık" değerini girin (Yüksek ağırlık, o değişkeni minimize etmeyi daha önemli kılar).', '3. "Min." ve "Maks." arama sınırlarını belirleyin.', '4. "Hedef Link Marjı"nı (ör: 3 dB) kısıt olarak girin.', '5. Başlat butonuna basın. Algoritma, hedef marjı sağlayan en düşük ağırlıklı maliyete sahip (güç, çap) kombinasyonunu bulacaktır.' };
        uicontrol(pnl_optimizasyon, 'Style','text','String',aciklama_metni,'Position',[580, 360, 300, 120],'BackgroundColor',renkler.panel_turuncu, 'HorizontalAlignment','left', 'FontSize', 9);
    
    % --- TAB 4 ---
    handles.tab_lazer = uitab(handles.ana_tab_grubu, 'Title', '4. Optik Haberleşme (Lazer)', 'BackgroundColor', renkler.tab_lazer_bg);
    
    pnl_opt_tx = uipanel(handles.tab_lazer, 'Title', 'OPTİK VERICI (Tx)', 'FontSize', 11, 'FontWeight', 'bold', ...
        'Position', [0.02, 0.55, 0.30, 0.40], 'BackgroundColor', renkler.opt_panel_bg, 'ForegroundColor', 'black', 'BorderType', 'line', 'HighlightColor', 'white');
        y = 120;
        uicontrol(pnl_opt_tx, 'Style','text','String','Dalga Boyu (nm):', 'Position',[10, y, 130, 20], 'BackgroundColor', renkler.opt_panel_bg, 'ForegroundColor', renkler.opt_yazi);
        handles.h_opt_lambda = uicontrol(pnl_opt_tx, 'Style','edit','String',num2str(uyduVerileri.optik.dalga), 'Position',[150, y, 80, 22]); y=y-35;
        
        uicontrol(pnl_opt_tx, 'Style','text','String','Lazer Gücü (W):', 'Position',[10, y, 130, 20], 'BackgroundColor', renkler.opt_panel_bg, 'ForegroundColor', renkler.opt_yazi);
        handles.h_opt_guc = uicontrol(pnl_opt_tx, 'Style','edit','String',num2str(uyduVerileri.optik.guc), 'Position',[150, y, 80, 22]); y=y-35;
        
        uicontrol(pnl_opt_tx, 'Style','text','String','Tx Teleskop Çapı (cm):', 'Position',[10, y, 140, 20], 'BackgroundColor', renkler.opt_panel_bg, 'ForegroundColor', renkler.opt_yazi);
        handles.h_opt_txCap = uicontrol(pnl_opt_tx, 'Style','edit','String',num2str(uyduVerileri.optik.txCap), 'Position',[150, y, 80, 22]); y=y-35;
        
        uicontrol(pnl_opt_tx, 'Style','text','String','Hüzme (mrad):', 'Position',[10, y, 130, 20], 'BackgroundColor', renkler.opt_panel_bg, 'ForegroundColor', renkler.opt_yazi);
        handles.h_opt_huzme = uicontrol(pnl_opt_tx, 'Style','edit','String',num2str(uyduVerileri.optik.huzme), 'Position',[150, y, 80, 22]);
    pnl_opt_rx = uipanel(handles.tab_lazer, 'Title', 'OPTİK ALICI (Rx)', 'FontSize', 11, 'FontWeight', 'bold', ...
        'Position', [0.34, 0.55, 0.30, 0.40], 'BackgroundColor', renkler.opt_panel_bg, 'ForegroundColor', 'black', 'BorderType', 'line', 'HighlightColor', 'white');
        y = 120;
        uicontrol(pnl_opt_rx, 'Style','text','String','Rx Teleskop Çapı (cm):', 'Position',[10, y, 140, 20], 'BackgroundColor', renkler.opt_panel_bg, 'ForegroundColor', renkler.opt_yazi);
        handles.h_opt_rxCap = uicontrol(pnl_opt_rx, 'Style','edit','String',num2str(uyduVerileri.optik.rxCap), 'Position',[150, y, 80, 22]); y=y-35;
        
        uicontrol(pnl_opt_rx, 'Style','text','String','Optik Verim (0-1):', 'Position',[10, y, 140, 20], 'BackgroundColor', renkler.opt_panel_bg, 'ForegroundColor', renkler.opt_yazi);
        handles.h_opt_verimRx = uicontrol(pnl_opt_rx, 'Style','edit','String','0.7', 'Position',[150, y, 80, 22]); y=y-35;
        
        uicontrol(pnl_opt_rx, 'Style','text','String','Hassasiyet (dBm):', 'Position',[10, y, 140, 20], 'BackgroundColor', renkler.opt_panel_bg, 'ForegroundColor', renkler.opt_yazi);
        handles.h_opt_sens = uicontrol(pnl_opt_rx, 'Style','edit','String',num2str(uyduVerileri.optik.sens), 'Position',[150, y, 80, 22]);
    pnl_opt_kanal = uipanel(handles.tab_lazer, 'Title', 'KANAL & HATA', 'FontSize', 11, 'FontWeight', 'bold', ...
        'Position', [0.66, 0.55, 0.32, 0.40], 'BackgroundColor', renkler.opt_panel_bg, 'ForegroundColor', 'black', 'BorderType', 'line', 'HighlightColor', 'white');
        y = 120;
        uicontrol(pnl_opt_kanal, 'Style','text','String','Mesafe (km):', 'Position',[10, y, 140, 20], 'BackgroundColor', renkler.opt_panel_bg, 'ForegroundColor', renkler.opt_yazi);
        handles.h_opt_mesafe = uicontrol(pnl_opt_kanal, 'Style','edit','String',num2str(uyduVerileri.optik.mesafe), 'Position',[160, y, 80, 22]); y=y-35;
        
        uicontrol(pnl_opt_kanal, 'Style','text','String','Atmosferik (dB/km):', 'Position',[10, y, 140, 20], 'BackgroundColor', renkler.opt_panel_bg, 'ForegroundColor', renkler.opt_yazi);
        handles.h_opt_atm = uicontrol(pnl_opt_kanal, 'Style','edit','String',num2str(uyduVerileri.optik.atm), 'Position',[160, y, 80, 22]); y=y-35;
        
        uicontrol(pnl_opt_kanal, 'Style','text','String','Hizalama Hatası (mrad):', 'Position',[10, y, 150, 20], 'BackgroundColor', renkler.opt_panel_bg, 'ForegroundColor', renkler.opt_yazi);
        handles.h_opt_hata = uicontrol(pnl_opt_kanal, 'Style','edit','String',num2str(uyduVerileri.optik.hata), 'Position',[160, y, 80, 22]);
    uicontrol(handles.tab_lazer, 'Style', 'pushbutton', 'String', 'HESAPLA', 'FontSize', 16, 'FontWeight', 'bold', ...
        'Position', [400, 200, 200, 50], 'BackgroundColor', renkler.opt_buton, 'ForegroundColor', 'white', 'Callback', @optik_hesapla_callback);
    pnl_opt_sonuc = uipanel(handles.tab_lazer, 'Title', 'ANALİZ SONUÇLARI', 'FontSize', 11, 'FontWeight', 'bold', ...
        'Position', [0.02, 0.02, 0.96, 0.23], 'BackgroundColor', [1 1 1], 'ForegroundColor', 'black');
    handles.optik_sonuc_list = uicontrol(pnl_opt_sonuc, 'Style', 'listbox', 'String', {'Sonuçlar burada görünecek...'}, ...
        'Position', [10, 10, 1000, 110], 'FontSize', 11, 'FontName', 'Courier New', 'BackgroundColor', 'white', 'ForegroundColor', 'black');
    
    % --- CALLBACK FONKSİYONLARI ---
    
    function optik_hesapla_callback(~,~)
        try
            lam = str2double(get(handles.h_opt_lambda, 'String')) * 1e-9;
            P_w = str2double(get(handles.h_opt_guc, 'String'));
            D_tx = str2double(get(handles.h_opt_txCap, 'String'))/100;
            D_rx = str2double(get(handles.h_opt_rxCap, 'String'))/100;
            R = str2double(get(handles.h_opt_mesafe, 'String')) * 1000;
            huzme = str2double(get(handles.h_opt_huzme, 'String')) * 1e-3;
            hata = str2double(get(handles.h_opt_hata, 'String')) * 1e-3;
            atm_db = str2double(get(handles.h_opt_atm, 'String'));
            sens = str2double(get(handles.h_opt_sens, 'String'));
            verim = str2double(get(handles.h_opt_verimRx, 'String'));
            
            if any(isnan([lam, P_w, D_tx, D_rx, R]))
                msgbox('Lütfen sayısal değer giriniz.', 'Hata'); return; 
            end
            
            P_tx_dbm = 10*log10(P_w*1000);
            G_tx = 10*log10(0.8 * (pi*D_tx/lam)^2);
            G_rx = 10*log10(verim * (pi*D_rx/lam)^2);
            L_fspl = 20*log10(4*pi*R/lam);
            L_atm = atm_db * (R/1000); if (R/1000)>20, L_atm = atm_db*20; end
            L_point = 4.343 * (hata/(huzme/2))^2; 
            
            P_rx = P_tx_dbm + G_tx + G_rx - L_fspl - L_atm - L_point - 3.0; 
            Marj = P_rx - sens;
            
            res = {
                sprintf(' --- OPTİK ANALİZ SONUCU ---'),
                sprintf(' Mesafe: %.2f km, Dalga Boyu: %.0f nm', R/1000, lam*1e9),
                sprintf(' Tx Güç: %.2f dBm, Kazançlar: Tx=%.1f dBi, Rx=%.1f dBi', P_tx_dbm, G_tx, G_rx),
                sprintf(' Kayıplar: FSPL=%.2f dB, Atmosfer=%.2f dB, Pointing=%.2f dB', L_fspl, L_atm, L_point),
                sprintf(' ALINAN GÜÇ: %.2f dBm (Hassasiyet: %.1f dBm)', P_rx, sens),
                sprintf(' >> LİNK MARJI: %.2f dB <<', Marj)
            };
            set(handles.optik_sonuc_list, 'String', res);
            
            if Marj > 0
                set(handles.optik_sonuc_list, 'ForegroundColor', [0 0.5 0]); 
            else
                set(handles.optik_sonuc_list, 'ForegroundColor', 'red');
            end
        catch ME
            msgbox(['Hata oluştu: ' ME.message], 'Hata');
        end
    end
    
    function guncelle_kayip_grafigi()
        if isempty(uyduVerileri.sonuclar)
            cla(handles.loss_axes); 
            title(handles.loss_axes, 'Lütfen ana "Hesapla" butonuna basın');
            return;
        end
        
        
        k = uyduVerileri.kayiplar;
        loss_data = [k.fsl, k.polarizasyon, k.yonlendirme, k.yagmur, k.gaz, k.diger];
        loss_labels = {'FSL', 'Polarizasyon', 'Yönlendirme', 'Yağmur', 'Gaz', 'Diğer'};
        
        
        bar(handles.loss_axes, loss_data);
        
        
        set(handles.loss_axes, 'XTickLabel', loss_labels);
        
        title(handles.loss_axes, 'Kayıp Dökümü (Maks. İrtifa/Varsayılan)');
        ylabel(handles.loss_axes, 'Kayıp (dB)');
        grid(handles.loss_axes, 'on');
    end
    
    function kaydet_ve_hesapla_callback(~,~)
        try
            uyduVerileri.sistem.uyduAdi = get(handles.h_sistem_uyduAdi, 'String'); 
            uyduVerileri.sistem.siteAdi = get(handles.h_sistem_siteAdi, 'String'); 
            uyduVerileri.sistem.antenTipi = get(handles.h_sistem_antenTipi, 'Value');
            uyduVerileri.sistem.band = get(handles.h_sistem_band, 'Value');
            
            uyduVerileri.sistem.uydu_enlem = str2double(get(handles.h_sistem_uyduEnlem, 'String'));
            uyduVerileri.sistem.uydu_boylam = str2double(get(handles.h_sistem_uyduBoylam, 'String'));
            uyduVerileri.sistem.uydu_irtifa = str2double(get(handles.h_sistem_uydu_irtifa, 'String'));
            uyduVerileri.sistem.yer_enlem = str2double(get(handles.h_sistem_yerEnlem, 'String'));
            uyduVerileri.sistem.yer_boylam = str2double(get(handles.h_sistem_yerBoylam, 'String'));
            uyduVerileri.sistem.yer_irtifa = str2double(get(handles.h_sistem_yer_irtifa, 'String'));
            
            uyduVerileri.verici.frekans = str2double(get(handles.h_verici_frekans, 'String'));
            uyduVerileri.verici.guc = str2double(get(handles.h_verici_guc, 'String'));
            uyduVerileri.verici.capT = str2double(get(handles.h_verici_capT, 'String'));
            uyduVerileri.verici.txKayip = str2double(get(handles.h_verici_txKayip, 'String'));
            uyduVerileri.verici.modKayip = str2double(get(handles.h_verici_modKayip, 'String'));
            uyduVerileri.verici.bantGenisligi = str2double(get(handles.h_verici_bantGenisligi, 'String'));
            uyduVerileri.verici.kodlamaKazanci = str2double(get(handles.h_verici_kodlamaKazanci, 'String'));
            
            uyduVerileri.alici.esikSN = str2double(get(handles.h_alici_esikSN, 'String'));
            uyduVerileri.alici.capR = str2double(get(handles.h_alici_capR, 'String'));
            uyduVerileri.alici.sicaklik = str2double(get(handles.h_alici_sicaklik, 'String'));
            
            uyduVerileri.alici.interferenceLoss = str2double(get(handles.h_alici_interference, 'String'));
            uyduVerileri.alici.rxFeederLoss = str2double(get(handles.h_alici_feederLoss, 'String'));
            uyduVerileri.alici.otherRxLoss = str2double(get(handles.h_alici_otherLoss, 'String'));
            uyduVerileri.alici.gtTarget = str2double(get(handles.h_alici_gtTarget, 'String'));
            
            uyduVerileri.alici.rxKayip = uyduVerileri.alici.rxFeederLoss + uyduVerileri.alici.otherRxLoss; 
            
        catch ME
            msgbox(sprintf('Girdi hatası: %s', ME.message), 'Hata');
            return;
        end
        
        hesapla_callback(); 
        guncellenmis_sonuclari_goster();
        guncellenmis_link_durumu_goster(); 
        guncelle_kayip_grafigi(); 
        
        ciz_fsl_grafigi();
        ciz_kontur_grafigi();
        
        if ~isempty(uyduVerileri.sonuclar)
             h_g_val = num2str(uyduVerileri.sonuclar.kazanc_r, '%.2f');
             set(handles.h_gt_g, 'String', h_g_val);
             set(handles.h_gt_t, 'String', num2str(uyduVerileri.alici.sicaklik));
        end
        
        if nargin > 0
            msgbox('Girdiler kaydedildi ve genel hesaplama tamamlandı.', 'Başarılı');
        end
    end
    
    function hesapla_callback(~,~)
        
        [X_yer, Y_yer, Z_yer] = geodetic_to_ecef(uyduVerileri.sistem.yer_enlem, uyduVerileri.sistem.yer_boylam, uyduVerileri.sistem.yer_irtifa);
        [X_uydu, Y_uydu, Z_uydu] = geodetic_to_ecef(uyduVerileri.sistem.uydu_enlem, uyduVerileri.sistem.uydu_boylam, uyduVerileri.sistem.uydu_irtifa);
        
        range_m = sqrt((X_uydu - X_yer)^2 + (Y_uydu - Y_yer)^2 + (Z_uydu - Z_yer)^2);
        d_km = range_m / 1000;
        if d_km <= 0 || d_km > 150000 
             msgbox(sprintf('Hata: Hesaplanan coğrafi menzil (%.2f km) geçersiz.', d_km), 'Hata', 'error');
             return;
        end
        
        uyduVerileri.kayiplar.fsl = 92.45 + 20*log10(d_km) + 20*log10(uyduVerileri.verici.frekans); 
        
        sonuc = anlik_hesapla(uyduVerileri.verici, uyduVerileri.alici, uyduVerileri.kayiplar, d_km);
        uyduVerileri.sonuclar = sonuc;
    end
    
    
    function sonuclar = anlik_hesapla(v, a, k, d_km)
        c = 299792458; kb = 1.380649e-23; anten_verimi = 0.6;
        
        bit_hizi_bps = 9600; 
        kodlama_kazanci_db = v.kodlamaKazanci; 
        
        if v.guc <= 0 || v.capT <= 0 || a.capR <= 0 || v.frekans <= 0 || a.sicaklik <= 0 || v.bantGenisligi <= 0
            error('Hesaplama hatası: Güç, Çap, Frekans, Sıcaklık ve Bant Genisliği 0''dan büyük olmalıdır.');
        end
        if d_km <= 0
             error('Hesaplama hatası: Mesafe (d_km) 0''dan büyük olmalıdır.');
        end
        
        frekans_hz = v.frekans * 1e9;
        dalgaboyu_m = c / frekans_hz;
        guc_dbw = 10 * log10(v.guc);
        kazanc_t_db = 10 * log10(anten_verimi * (pi * v.capT / dalgaboyu_m)^2);
        kazanc_r_db = 10 * log10(anten_verimi * (pi * a.capR / dalgaboyu_m)^2);
        
        toplam_kayip_db = k.fsl + k.polarizasyon + k.yonlendirme + k.yagmur + k.gaz + k.diger + v.modKayip + a.interferenceLoss;
        
        eirp_dbw = guc_dbw + kazanc_t_db - v.txKayip;
        gt_db_k = kazanc_r_db - 10 * log10(a.sicaklik);
        
        alinan_sinyal_dbm = (eirp_dbw + 30) + kazanc_r_db - toplam_kayip_db - a.rxKayip;
        bant_genisligi_hz = v.bantGenisligi * 1e6;
        gurultu_gucu_dbm = 10*log10(kb * a.sicaklik * bant_genisligi_hz) + 30;
        sn_db = alinan_sinyal_dbm - gurultu_gucu_dbm;
        
        ebno_db = sn_db - 10*log10(bant_genisligi_hz / bit_hizi_bps);
        
        link_marjini = sn_db - a.esikSN + kodlama_kazanci_db;
        
        verici_ar = pi * (v.capT/2)^2; alici_ar = pi * (a.capR/2)^2;
        verici_ae = verici_ar * anten_verimi; alici_ae = alici_ar * anten_verimi;
        gurultu_figuru = 10*log10(1 + (a.sicaklik / 290));
        huzme_genisligi_t = 70 * dalgaboyu_m / v.capT;
        huzme_genisligi_r = 70 * dalgaboyu_m / a.capR;
        
        sonuclar = struct('dalgaboyu', dalgaboyu_m, 'guc_dbm', guc_dbw+30, 'kazanc_t', kazanc_t_db, ...
            'toplam_kayip', toplam_kayip_db, 'eirp_dbm', eirp_dbw+30, 'kazanc_r', kazanc_r_db, ...
            'gt', gt_db_k, 'alinan_sinyal', alinan_sinyal_dbm, 'sn', sn_db, 'link_marjini', link_marjini, ...
            'verici_ar', verici_ar, 'alici_ar', alici_ar, 'verici_ae', verici_ae, 'alici_ae', alici_ae, ...
            'gurultu_figuru', gurultu_figuru, 'mesafe', d_km, 'huzme_t', huzme_genisligi_t, 'huzme_r', huzme_genisligi_r, ...
            'ebno', ebno_db);
    end
    
    
    % --- SONUÇ GÖSTERME (MODİFİYE EDİLDİ) ---
    function guncellenmis_sonuclari_goster()
        if isempty(uyduVerileri.sonuclar)
            set(handles.sonuc_listbox, 'String', {'Önce HESAPLA butonuna basın.'});
            set(handles.sonuc_listbox, 'ForegroundColor', 'black'); 
            return; 
        end
        
        s = uyduVerileri.sonuclar; v = uyduVerileri.verici; a = uyduVerileri.alici;
        
        sonuc_listesi = {
            '--- GENEL ---', ...
            sprintf(' Frekans (GHz):          %10.3f', v.frekans), ...
            sprintf(' Mesafe (km):              %10.2f', s.mesafe), ...
            sprintf(' Dalga Boyu (m):           %10.4f', s.dalgaboyu), ...
            sprintf(' Toplam Kayıp (dB):        %10.2f', s.toplam_kayip), ...
            '--- VERİCİ (Tx) ---', ...
            sprintf(' Verici Gücü (dBm):        %10.2f', s.guc_dbm), ...
            sprintf(' Anten Kazancı (dBi):      %10.2f', s.kazanc_t), ...
            sprintf(' Hüzme Genişliği (deg):    %10.3f', s.huzme_t), ...
            sprintf(' EIRP (dBm):               %10.2f', s.eirp_dbm), ...
            sprintf(' Kodlama Kazancı (dB):     %10.2f', v.kodlamaKazanci), ... 
            '--- ALICI (Rx) ---', ...
            sprintf(' Anten Kazancı (dBi):      %10.2f', s.kazanc_r), ...
            sprintf(' Hüzme Genişliği (deg):    %10.3f', s.huzme_r), ...
            sprintf(' Sistem Gürültü Sıck. (K): %10.1f', a.sicaklik), ...
            sprintf(' Gürültü Figürü (dB):      %10.2f', s.gurultu_figuru), ...
            sprintf(' G/T (dB/K):               %10.2f', s.gt), ...
            sprintf(' Parazit Kaybı (dB):       %10.2f', a.interferenceLoss), ...
            sprintf(' Feeder/Diğer Rx Kayıp(dB):%10.2f', a.rxKayip), ...
            '--- PERFORMANS ---', ...
            sprintf(' Alınan Sinyal (dBm):      %10.2f', s.alinan_sinyal), ...
            sprintf(' RSSI (dBm):               %10.2f', s.alinan_sinyal), ... % <--- RSSI SATIRI EKLENDİ
            sprintf(' Hesaplanan SNR (S/N) (dB):%10.2f', s.sn), ...
            sprintf(' Hesaplanan Eb/No (dB):    %10.2f', s.ebno), ...
            '-------------------------------------------', ...
            sprintf(' LİNK MARJI (dB):          %10.2f', s.link_marjini)
        };
        
        set(handles.sonuc_listbox, 'String', sonuc_listesi);
        
        if s.link_marjini >= 0
            set(handles.sonuc_listbox, 'ForegroundColor', [0 0.4 0]); 
        else
            set(handles.sonuc_listbox, 'ForegroundColor', 'red');
        end
    end
    function guncellenmis_link_durumu_goster()
        if isempty(uyduVerileri.sonuclar), return; end
        marjin = uyduVerileri.sonuclar.link_marjini;
        if marjin > 0
            set(handles.link_durumu_text, 'String', sprintf('OPEN (%.2f dB)', marjin), 'BackgroundColor', [0.7 1 0.7]); 
        else
            set(handles.link_durumu_text, 'String', sprintf('CLOSED (%.2f dB)', marjin), 'BackgroundColor', [1 0.7 0.7]); 
        end
    end
    
    function simulasyonu_calistir_callback(~,~)
        H_max = str2double(get(handles.h_sim_irtifa,'String')); 
        V_desc = str2double(get(handles.h_sim_hiz,'String'));
        drawnow;
        
        if isnan(H_max) || isnan(V_desc) || H_max <= 0 || V_desc <= 0
            msgbox('Simülasyon girdileri geçersiz (Maks İrtifa > 0 ve Hız > 0 olmalı).', 'Hata', 'warn');
            return;
        end
        
        T_total = H_max / V_desc;
        time_vec = 0:1:floor(T_total);
        if isempty(time_vec), time_vec = [0 T_total]; end 
            
        margin_vec = zeros(size(time_vec));
        rssi_vec = zeros(size(time_vec)); 
        h_wait = waitbar(0, 'Uçuş simülasyonu yapılıyor...');
        
        phi_yer = uyduVerileri.sistem.yer_enlem;
        lambda_yer = uyduVerileri.sistem.yer_boylam;
        h_yer = uyduVerileri.sistem.yer_irtifa;
        
        try
            for i = 1:length(time_vec)
                current_t = time_vec(i);
                current_h = H_max - V_desc * current_t; 
                if current_h < 1, current_h = 1; end
                
                phi_uydu = uyduVerileri.sistem.uydu_enlem;
                lambda_uydu = uyduVerileri.sistem.uydu_boylam;
                h_uydu = current_h; 
                
                [X_yer, Y_yer, Z_yer] = geodetic_to_ecef(phi_yer, lambda_yer, h_yer);
                [X_uydu, Y_uydu, Z_uydu] = geodetic_to_ecef(phi_uydu, lambda_uydu, h_uydu);
                range_m = sqrt((X_uydu - X_yer)^2 + (Y_uydu - Y_yer)^2 + (Z_uydu - Z_yer)^2);
                d_km = range_m / 1000;
                
                f_ghz = uyduVerileri.verici.frekans;
                current_fsl = 92.45 + 20*log10(d_km) + 20*log10(f_ghz);
                temp_kayiplar = uyduVerileri.kayiplar;
                temp_kayiplar.fsl = current_fsl;
                
                sonuclar = anlik_hesapla(uyduVerileri.verici, uyduVerileri.alici, temp_kayiplar, d_km); 
                
                margin_vec(i) = sonuclar.link_marjini;
                rssi_vec(i) = sonuclar.alinan_sinyal; 
                waitbar(i/length(time_vec), h_wait, sprintf('Hesaplanan Zaman: %d s', round(current_t)));
            end
        catch ME
             close(h_wait);
             msgbox(sprintf('Simülasyon sırasında bir hata oluştu:\n%s', ME.message), 'Hata', 'error'); 
             return;
        end
        
        close(h_wait); 
        
        uyduVerileri.sim_results = struct('zaman', time_vec, 'marjin', margin_vec, 'irtifa', H_max);
        
        
        hesapla_callback(); 
        guncellenmis_sonuclari_goster();
        guncellenmis_link_durumu_goster(); 
        guncelle_kayip_grafigi(); 
        
        ax = handles.sim_axes; 
        
        yyaxis(ax, 'left');
        plot(ax, time_vec, margin_vec, 'LineWidth', 2.5, 'Color', renkler.cizgi);
        ylabel(ax, 'Link Marjı (dB)');
        ax.YColor = renkler.cizgi;
        
        yyaxis(ax, 'right');
        plot(ax, time_vec, rssi_vec, 'LineWidth', 2.0, 'Color', [0, 0.6, 0.2]);
        ylabel(ax, 'RSSI (dBm)');
        ax.YColor = [0, 0.6, 0.2];
        
        grid(ax, 'on'); box(ax, 'on');
        title(ax, sprintf('Uçuş Boyunca Link Marjı ve RSSI (Maks. İrtifa: %d m)', H_max), 'FontSize', 12, 'Color', renkler.baslik);
        xlabel(ax, 'Geçen Süre (saniye)'); 
        
        yline(ax, 0, 'r--', 'LineWidth', 2);
        legend(ax, 'Link Marjı', 'RSSI (dBm)', 'Location', 'best');
    end
    
    
    function ciz_fsl_grafigi()
        d_range_m = 100:1000:1000000; 
        d_range_km = d_range_m / 1000;
        
        f_ghz = uyduVerileri.verici.frekans;
        
        fsl_values = 92.45 + 20*log10(d_range_km) + 20*log10(f_ghz); 
        
        ax = handles.fsl_axes;
        cla(ax); 
        plot(ax, d_range_km, fsl_values, 'LineWidth', 2, 'Color', [0.0, 0.5, 0.8]); 
        
        if ~isempty(uyduVerileri.sonuclar)
            current_d_km = uyduVerileri.sonuclar.mesafe;
            current_fsl = uyduVerileri.kayiplar.fsl;
            hold(ax, 'on');
            plot(ax, current_d_km, current_fsl, 'r*', 'MarkerSize', 10, 'LineWidth', 1.5); 
            text(ax, current_d_km, current_fsl, ' Aktif Nokta', 'VerticalAlignment', 'bottom', 'Color', 'r');
            hold(ax, 'off');
        end
        
        title(ax, sprintf('FSL (dB) vs. Mesafe (GHz: %.3f)', f_ghz));
        xlabel(ax, 'Mesafe (km)');
        ylabel(ax, 'FSL (dB)');
        grid(ax, 'on');
    end
    function ciz_kontur_grafigi()
        Tx_HPA_dbw_range = 0:1:30; 
        Distance_km_range = 1:50:6000; 
        
        Margin_matrix = zeros(length(Distance_km_range), length(Tx_HPA_dbw_range));
        
        v_base = uyduVerileri.verici;
        a_base = uyduVerileri.alici;
        k_base = uyduVerileri.kayiplar;
        
        h_wait = waitbar(0, 'Kontur grafiği verileri hesaplanıyor...');
        
        try
            for i = 1:length(Distance_km_range)
                d_km = Distance_km_range(i);
                
                f_ghz = v_base.frekans;
                current_fsl = 92.45 + 20*log10(d_km) + 20*log10(f_ghz);
                
                temp_kayiplar = k_base;
                temp_kayiplar.fsl = current_fsl;
                
                for j = 1:length(Tx_HPA_dbw_range)
                    tx_hpa_dbw = Tx_HPA_dbw_range(j);
                    
                    guc_w = 10^(tx_hpa_dbw / 10);
                    v_temp = v_base;
                    v_temp.guc = guc_w;
                    
                    sonuc = anlik_hesapla(v_temp, a_base, temp_kayiplar, d_km);
                    Margin_matrix(i, j) = sonuc.link_marjini;
                end
                waitbar(i/length(Distance_km_range), h_wait);
            end
        catch ME
            close(h_wait);
            msgbox(sprintf('Kontur hesaplama sırasında hata: %s', ME.message), 'Hata', 'error');
            return;
        end
        
        close(h_wait);
        
        ax = handles.kontur_axes;
        cla(ax);
        
        seviyeler = [-10, -5, 0, 5, 10, 15, 20, 25, 30]; 
        
        contourf(ax, Tx_HPA_dbw_range, Distance_km_range/1000, Margin_matrix, seviyeler, 'LineStyle', '-', 'LineColor', [0.4 0.4 0.4]); 
        colormap(ax, jet); 
        
        c = colorbar(ax);
        c.Label.String = 'Link Marjı (dB)';
        
        xlabel(ax, 'Tx HPA Gücü (dBW)');
        ylabel(ax, 'Mesafe (km)');
        title(ax, 'Link Marjı Kontur Analizi');
        grid(ax, 'on'); box(ax, 'on');
        
        if ~isempty(uyduVerileri.sonuclar)
            d_op = uyduVerileri.sonuclar.mesafe;
            tx_op = 10*log10(uyduVerileri.verici.guc); 
            hold(ax, 'on');
            plot(ax, tx_op, d_op, 'r*', 'MarkerSize', 12, 'LineWidth', 2);
            text(ax, tx_op, d_op, ' Opr. Noktası', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left', 'Color', 'r', 'FontWeight', 'bold');
            hold(ax, 'off');
        end
    end
    
    
    function hesapla_fsl_callback(~,~)
        d = str2double(get(handles.h_fsl_mesafe, 'String')); 
        f = str2double(get(handles.h_fsl_frekans, 'String'));
        fsl = 92.45 + 20*log10(d) + 20*log10(f);
        set(handles.h_fsl_sonuc, 'String', sprintf('%.2f dB', fsl));
        uyduVerileri.kayiplar.fsl = fsl; 
        msgbox(sprintf('Serbest Uzay Kaybı %.2f dB olarak eklendi.', fsl));
        guncelle_kayip_grafigi(); 
    end
    function hesapla_pol_callback(~,~)
        phi = str2double(get(handles.h_pol_aci, 'String'));
        loss = -20 * log10(cosd(phi));
        set(handles.h_pol_sonuc, 'String', sprintf('%.2f dB', loss));
        uyduVerileri.kayiplar.polarizasyon = loss;
        msgbox(sprintf('Polarizasyon Kaybı %.2f dB olarak eklendi.', loss));
        guncelle_kayip_grafigi(); 
    end
    
    function hesapla_point_callback(~,~)
        D = str2double(get(handles.h_point_cap, 'String')); 
        f = str2double(get(handles.h_point_frekans, 'String')); 
        theta_e = str2double(get(handles.h_point_hata, 'String'));
        c = 3e8; lambda = c / (f * 1e9);
        huzme_genisligi = 70 * lambda / D;
        loss = 12 * (theta_e / huzme_genisligi)^2;
        set(handles.h_point_sonuc, 'String', sprintf('%.2f dB', loss));
        uyduVerileri.kayiplar.yonlendirme = loss;
        msgbox(sprintf('Yönlendirme Kaybı %.2f dB olarak eklendi.', loss));
        guncelle_kayip_grafigi(); 
    end
    
    function hesapla_rain_callback(~,~)
        f = str2double(get(handles.h_rain_frekans, 'String'));
        R = str2double(get(handles.h_rain_yagmur, 'String'));
        L = str2double(get(handles.h_rain_yol, 'String'));
        elev = str2double(get(handles.h_rain_elev, 'String'));
        if isnan(f) || isnan(R) || isnan(L) || isnan(elev) || elev <= 0
            set(handles.h_rain_sonuc, 'String', 'Geçersiz!'); return;
        end
        k_coeff = 0.0004; alpha = 1.1; 
        loss_specific = k_coeff * (R^alpha); 
        effective_L = L / sind(elev); 
        loss = loss_specific * effective_L;
        if f > 6, loss = loss * (f/6); end
        set(handles.h_rain_sonuc, 'String', sprintf('%.3f dB', loss));
        uyduVerileri.kayiplar.yagmur = loss;
        msgbox(sprintf('Yağmur Zayıflaması %.3f dB olarak eklendi.', loss));
        guncelle_kayip_grafigi(); 
    end
    
    function hesapla_gas_callback(~,~)
        T_C = str2double(get(handles.h_gas_temp, 'String'));
        f = str2double(get(handles.h_gas_freq, 'String'));
        L = str2double(get(handles.h_gas_path, 'String'));
        P = str2double(get(handles.h_gas_press, 'String'));
        rho = str2double(get(handles.h_gas_density, 'String'));
        if isnan(T_C) || isnan(f) || isnan(L) || isnan(P) || isnan(rho)
             set(handles.h_gas_sonuc, 'String', 'Geçersiz!'); return;
        end
        k_o2 = (0.01 * (P/1013) * (f^2)) / (1 + (f-60)^2);
        k_h2o = (0.01 * (rho/7.5) * (f^2)) / (1 + (f-22.2)^2);
        if f < 10, k_o2 = 0.001; k_h2o = 0.001; end
        loss = (k_o2 + k_h2o) * L;
        set(handles.h_gas_sonuc, 'String', sprintf('%.3f dB', loss));
        uyduVerileri.kayiplar.gaz = loss;
        msgbox(sprintf('Gaz Soğurması %.3f dB olarak eklendi.', loss));
        guncelle_kayip_grafigi(); 
    end
    
    function hesapla_antgain_callback(~,~)
        f_ghz = str2double(get(handles.h_antgain_freq, 'String'));
        D = str2double(get(handles.h_antgain_cap, 'String'));
        eta = str2double(get(handles.h_antgain_verim, 'String'));
        if any(isnan([f_ghz, D, eta])) || f_ghz <= 0 || D <= 0 || eta <= 0 || eta > 1
            set(handles.h_antgain_sonuc, 'String', 'Geçersiz!'); return;
        end
        c = 3e8; lambda = c / (f_ghz * 1e9);
        gain_db = 10 * log10(eta * (pi * D / lambda)^2);
        set(handles.h_antgain_sonuc, 'String', sprintf('%.2f dBi', gain_db));
    end
    function hesapla_bw_callback(~,~)
        D = str2double(get(handles.h_bw_d, 'String'));
        f_ghz = str2double(get(handles.h_bw_f, 'String'));
        if isnan(D) || isnan(f_ghz) || D <= 0 || f_ghz <= 0
            set(handles.h_bw_sonuc, 'String', 'Geçersiz!'); return;
        end
        c = 3e8; lambda = c / (f_ghz * 1e9);
        bw = 70 * (lambda / D);
        set(handles.h_bw_sonuc, 'String', sprintf('%.3f deg', bw));
    end
    function hesapla_gt_callback(~,~)
        G_dbi = str2double(get(handles.h_gt_g, 'String'));
        T_k = str2double(get(handles.h_gt_t, 'String'));
        if isnan(G_dbi) || isnan(T_k) || T_k <= 0
            set(handles.h_gt_sonuc, 'String', 'Geçersiz!'); return;
        end
        G_T = G_dbi - 10*log10(T_k);
        set(handles.h_gt_sonuc, 'String', sprintf('%.2f dB/K', G_T));
    end
    function hesapla_antnoise_callback(~,~)
        T_sky = str2double(get(handles.h_antnoise_tsky, 'String'));
        T_p = str2double(get(handles.h_antnoise_tp, 'String'));
        eta = str2double(get(handles.h_antnoise_eta, 'String'));
        if any(isnan([T_sky, T_p, eta])) || eta < 0 || eta > 1
            set(handles.h_antnoise_sonuc, 'String', 'Geçersiz!'); return;
        end
        T_a = (eta * T_sky) + (1 - eta) * T_p;
        set(handles.h_antnoise_sonuc, 'String', sprintf('%.2f K', T_a));
    end
    function hesapla_focal_callback(~,~)
        D = str2double(get(handles.h_focal_d, 'String'));
        d_depth = str2double(get(handles.h_focal_depth, 'String'));
        if isnan(D) || isnan(d_depth) || D <= 0 || d_depth <= 0
            set(handles.h_focal_sonuc, 'String', 'Geçersiz!'); return;
        end
        f = (D^2) / (16 * d_depth);
        set(handles.h_focal_sonuc, 'String', sprintf('%.3f m', f));
    end
    function hesapla_power_callback(~,~)
        w_str = get(handles.h_power_w, 'String');
        dbm_str = get(handles.h_power_dbm, 'String');
        dbw_str = get(handles.h_power_dbw, 'String');
        if ~isempty(w_str)
            P_w = str2double(w_str); P_dbw = 10 * log10(P_w); P_dbm = P_dbw + 30;
            set(handles.h_power_dbm, 'String', sprintf('%.2f', P_dbm));
            set(handles.h_power_dbw, 'String', sprintf('%.2f', P_dbw));
        elseif ~isempty(dbm_str)
            P_dbm = str2double(dbm_str); P_dbw = P_dbm - 30; P_w = 10^(P_dbw / 10);
            set(handles.h_power_w, 'String', sprintf('%.4f', P_w));
            set(handles.h_power_dbw, 'String', sprintf('%.2f', P_dbw));
        elseif ~isempty(dbw_str)
            P_dbw = str2double(dbw_str); P_dbm = P_dbw + 30; P_w = 10^(P_dbw / 10);
            set(handles.h_power_w, 'String', sprintf('%.4f', P_w));
            set(handles.h_power_dbm, 'String', sprintf('%.2f', P_dbm));
        end
    end
    function hesapla_freq_callback(~,~)
        mhz_str = get(handles.h_freq_mhz, 'String');
        ghz_str = get(handles.h_freq_ghz, 'String');
        hz_str = get(handles.h_freq_hz, 'String');
        if ~isempty(mhz_str)
            f_mhz = str2double(mhz_str);
            set(handles.h_freq_ghz, 'String', num2str(f_mhz / 1000));
            set(handles.h_freq_hz, 'String', num2str(f_mhz * 1e6));
        elseif ~isempty(ghz_str)
            f_ghz = str2double(ghz_str);
            set(handles.h_freq_mhz, 'String', num2str(f_ghz * 1000));
            set(handles.h_freq_hz, 'String', num2str(f_ghz * 1e9));
        elseif ~isempty(hz_str)
            f_hz = str2double(hz_str);
            set(handles.h_freq_mhz, 'String', num2str(f_hz / 1e6));
            set(handles.h_freq_ghz, 'String', num2str(f_hz / 1e9));
        end
    end
    function hesapla_ntemp_callback(~,~)
        T_str = get(handles.h_ntemp_t, 'String');
        F_str = get(handles.h_ntemp_f, 'String');
        NF_str = get(handles.h_ntemp_nf, 'String');
        T0 = 290; 
        if ~isempty(NF_str)
            NF = str2double(NF_str); F = 10^(NF / 10); T = T0 * (F - 1);
            set(handles.h_ntemp_t, 'String', sprintf('%.2f', T));
            set(handles.h_ntemp_f, 'String', sprintf('%.3f', F));
        elseif ~isempty(F_str)
            F = str2double(F_str); T = T0 * (F - 1); NF = 10 * log10(F);
            set(handles.h_ntemp_t, 'String', sprintf('%.2f', T));
            set(handles.h_ntemp_nf, 'String', sprintf('%.2f', NF));
        elseif ~isempty(T_str)
            T = str2double(T_str); F = 1 + (T / T0); NF = 10 * log10(F);
            set(handles.h_ntemp_f, 'String', sprintf('%.3f', F));
            set(handles.h_ntemp_nf, 'String', sprintf('%.2f', NF));
        end
    end
    function hesapla_nf_callback(~,~)
        T_str = get(handles.h_nf_t, 'String');
        F_str = get(handles.h_nf_f, 'String');
        NF_str = get(handles.h_nf_nf, 'String');
        T0 = 290; 
        if ~isempty(T_str)
            T = str2double(T_str); F = 1 + (T / T0); NF = 10 * log10(F);
            set(handles.h_nf_f, 'String', sprintf('%.3f', F));
            set(handles.h_nf_nf, 'String', sprintf('%.2f', NF));
        elseif ~isempty(F_str)
            F = str2double(F_str); T = T0 * (F - 1); NF = 10 * log10(F);
            set(handles.h_nf_t, 'String', sprintf('%.2f', T));
            set(handles.h_nf_nf, 'String', sprintf('%.2f', NF));
        elseif ~isempty(NF_str)
            NF = str2double(NF_str); F = 10^(NF / 10); T = T0 * (F - 1);
            set(handles.h_nf_t, 'String', sprintf('%.2f', T));
            set(handles.h_nf_f, 'String', sprintf('%.3f', F));
        end
    end
    function hesapla_wave_callback(~,~)
        f_mhz = str2double(get(handles.h_wave_freq, 'String'));
        if ~isnan(f_mhz) && f_mhz > 0
            lambda = 300 / f_mhz;
            set(handles.h_wave_sonuc, 'String', sprintf('%.4f m', lambda));
        else
            set(handles.h_wave_sonuc, 'String', 'Geçersiz!');
        end
    end
    function hesapla_path_callback(~,~)
        H = str2double(get(handles.h_path_h, 'String'));
        El = str2double(get(handles.h_path_el, 'String'));
        if isnan(H) || isnan(El) || El <= 0 || El > 90
            set(handles.h_path_sonuc, 'String', 'Geçersiz!'); return;
        end
        L = H / sind(El);
        set(handles.h_path_sonuc, 'String', sprintf('%.2f km', L));
    end
    
    function rapor_olustur_ac(~,~)
        if isempty(uyduVerileri.sonuclar) || isempty(uyduVerileri.sim_results)
            msgbox('Rapor oluşturmak için önce "Uçuş Simülasyonu" yapmalısınız.', 'Hata'); return; end
        p = figure('Name', 'Analiz Raporu', 'NumberTitle', 'off', 'Position', [100,100,800,600], 'Color', 'w', 'MenuBar','none');
        uicontrol(p, 'Style','text','String','Uydu Haberleşme Analiz Raporu','FontSize',18,'FontWeight','bold','Position',[0,550,800,40],'BackgroundColor','w','ForegroundColor',renkler.baslik);
        uicontrol(p, 'Style','text','String',sprintf('Rapor Tarihi: %s\nSaat: %s', datestr(now, 'dd-mmm-yyyy'), datestr(now, 'HH:MM:SS')),'FontSize',9,'Position',[600,545,180,40],'BackgroundColor','w', 'HorizontalAlignment','left');
        
        pnl_girdi = uipanel(p,'Title','Girdi Parametreleri','FontWeight','bold','Position',[0.02,0.4,0.4,0.5],'BackgroundColor',renkler.tab1);
        pnl_sonuc = uipanel(p,'Title','Genel Sonuçlar (Maks. İrtifada)','FontWeight','bold','Position',[0.02,0.08,0.4,0.3],'BackgroundColor',renkler.tab3);
        
        s = uyduVerileri.sistem; v = uyduVerileri.verici; a = uyduVerileri.alici;
        girdi_listesi = {sprintf('Uydu Adı: %s', s.uyduAdi), sprintf('Yer İstasyonu: %s', s.siteAdi), ...
            sprintf('Frekans: %.3f GHz', v.frekans), sprintf('Verici Gücü: %.2f W', v.guc), ...
            sprintf('Verici Anten Ölçüsü: %.2f m', v.capT), sprintf('Alıcı Anten Ölçüsü: %.2f m', a.capR), ...
            sprintf('Eşik S/N Oranı: %.1f dB', a.esikSN), sprintf('Sistem Sıcaklığı: %.1f K', a.sicaklik)};
        uicontrol(pnl_girdi, 'Style','listbox','String',girdi_listesi,'Position',[10,10,290,220],'FontSize',9);
        res = uyduVerileri.sonuclar;
        sonuc_listesi = {sprintf('Toplam Kayıp: %.2f dB', res.toplam_kayip), sprintf('EIRP: %.2f dBm', res.eirp_dbm), ...
            sprintf('Alınan Sinyal Gücü: %.2f dBm', res.alinan_sinyal), sprintf('Hesaplanan SNR: %.2f dB', res.sn), ...
            sprintf('Hesaplanan Eb/No: %.2f dB', res.ebno), ...
            sprintf('Link Marjı: %.2f dB', res.link_marjini)};
        uicontrol(pnl_sonuc, 'Style','listbox','String',sonuc_listesi,'Position',[10,10,290,120],'FontSize',10,'FontWeight','bold');
        
        ax_rapor = axes(p, 'Position', [0.48, 0.15, 0.48, 0.7]);
        sim = uyduVerileri.sim_results;
        plot(ax_rapor, sim.zaman, sim.marjin, 'LineWidth', 2, 'Color', renkler.cizgi);
        grid on; box on; title('Uçuş Boyunca Link Marjı'); xlabel('Süre (s)'); ylabel('Link Marjı (dB)');
        yline(ax_rapor, 0, 'r--', 'LineWidth', 1.5, 'Label','Kritik Eşik');
        uicontrol(p, 'Style','pushbutton','String','Raporu Kaydet', 'Position',[50,15,150,30],'BackgroundColor',renkler.buton_ana,'ForegroundColor','w','Callback',@rapor_kaydet);
        function rapor_kaydet(~,~)
            [file, path] = uiputfile('analiz_raporu.png', 'Raporu Kaydet');
            if isequal(file,0), return; end
            exportgraphics(p, fullfile(path, file), 'Resolution', 300);
            msgbox('Rapor başarıyla kaydedildi.');
        end
    end
    function senaryo_kaydet(~,~)
        kaydet_ve_hesapla_callback([],[]); 
        [file, path] = uiputfile('*.mat', 'Senaryoyu Kaydet', 'cansat_senaryo1.mat');
        if isequal(file,0), return; end
        kaydedilecek_veriler = uyduVerileri; 
        save(fullfile(path, file), 'kaydedilecek_veriler');
        msgbox('Senaryo başarıyla kaydedildi.');
    end
    
    function formulleri_goster_ac(~,~)
        formula_list = {
            '--- ANA LİNK BÜTÇESİ ---', ...
            'EIRP (dBW) = Verici Gücü (dBW) + Verici Anten Kazancı (dBi) - Verici Kaybı (dB)', ...
            'Alınan Sinyal (dBm) = EIRP (dBm) + Alıcı Anten Kazancı (dBi) - Toplam Kayıp (dB) - Alıcı Kaybı (dB)', ...
            'Gürültü Gücü (dBm) = 10*log10(k * T * B) + 30', ...
            '    (k = Boltzmann sabiti, T = Sistem Sıcaklığı (K), B = Bant Genişliği (Hz))', ...
            'SNR (S/N) (dB) = Alınan Sinyal (dBm) - Gürültü Gücü (dBm)', ...
            'Eb/No (dB) = SNR (dB) - 10*log10(B/Rb)   (B=Bant Genişliği, Rb=Bit Hızı)', ... 
            'Link Marjı (dB) = SNR (dB) - Eşik SNR (dB) + Kodlama Kazancı (dB)', ... 
            '', ...
            '--- COĞRAFİ MENZİL VE FSL HESAPLARI (WGS84) ---', ...
            '1. Jeodezik Koordinatlardan ECEF (X, Y, Z) Dönüşümü Yapılır', ...
            '   a = 6378137.0 m (Yarı Büyük Eksen)', ...
            '   $e^2 = 2f - f^2$ (Basıklık Karesi)', ...
            '   N(φ) = $a / \sqrt{1 - e^2 \sin^2(\phi)}$ (Eğrilik Yarıçapı)', ...
            '   X = (N + h) cos(φ) cos(λ)', ...
            '   Y = (N + h) cos(φ) sin(λ)', ...
            '   Z = [N(1 - $e^2$) + h] sin(φ)', ...
            '2. Range (Mesafe) = $\sqrt{\Delta X^2 + \Delta Y^2 + \Delta Z^2}$ (km) (Uydu ve Yer İst. Arası)', ...
            '3. Serbest Uzay Kaybı (FSL) (dB) = 92.45 + 20*log10(Mesafe_km) + 20*log10(Frekans_GHz)', ...
            'Polarizasyon Kaybı (dB) = -20 * log10(cosd(Açı_Hatası))', ...
            'Yönlendirme Kaybı (dB) = 12 * (Yönlendirme_Hatası_deg / Hüzme_Genişliği_deg)^2', ...
            '', ...
            '--- ANTEN HESAPLARI ---', ...
            'Dalga Boyu (λ) (m) = c / Frekans_Hz   (veya 300 / Frekans_MHz)', ...
            'Anten Kazancı (dBi) = 10*log10(η * (π * D / λ)^2)', ...
            '    (η = Verimlilik, D = Anten Çapı, λ = Dalga Boyu)', ...
            'Hüzme Genişliği (deg) ≈ 70 * (λ / D)', ...
            'G/T (dB/K) = Alıcı Anten Kazancı (dBi) - 10*log10(Sistem_Sıcaklığı_K)', ...
            'Anten Gürültü Sıcaklığı (T_a) = (η * T_sky) + (1-η) * T_p', ...
            'Odak Mesafesi (f) = D² / (16 * d)   (D=Çap, d=Derinlik)',...
            '',...
            '--- DÖNÜŞTÜRÜCÜLER ---',...
            'Güç (dBm) = 10 * log10(Güç_W / 0.001)  (veya dBW + 30)',...
            'Gürültü Sıcaklığı (T) = 290 * (10^(NF_dB / 10) - 1)',...
            'Gürültü Figürü (NF) (dB) = 10 * log10(1 + (T / 290))'
        };
        h_fig_formuller = figure('Name', 'Kullanılan Formüller Listesi', 'NumberTitle', 'off', ...
                             'Position', [200, 200, 650, 450], 'Color', renkler.tab3, 'MenuBar', 'none');
        uicontrol('Parent', h_fig_formuller, 'Style', 'listbox', 'String', formula_list, ...
                  'Position', [10, 10, 630, 430], 'FontSize', 10, 'FontName', 'Courier New', ...
                  'BackgroundColor', [1, 1, 1], 'HorizontalAlignment', 'left');
    end
    
    function optimize_et_callback(~,~)
        opt_setup = struct();
        try
            opt_setup.degiskenler = {}; 
            opt_setup.lb = [];          
            opt_setup.ub = [];          
            opt_setup.agirliklar = [];  
            
            if get(handles.h_opt_cb_guc, 'Value') == 1
                opt_setup.degiskenler{end+1} = 'guc';
                opt_setup.lb(end+1) = str2double(get(handles.h_opt_lb_guc, 'String'));
                opt_setup.ub(end+1) = str2double(get(handles.h_opt_ub_guc, 'String'));
                opt_setup.agirliklar(end+1) = str2double(get(handles.h_opt_w_guc, 'String'));
            end
            if get(handles.h_opt_cb_capT, 'Value') == 1
                opt_setup.degiskenler{end+1} = 'capT';
                opt_setup.lb(end+1) = str2double(get(handles.h_opt_lb_capT, 'String'));
                opt_setup.ub(end+1) = str2double(get(handles.h_opt_ub_capT, 'String'));
                opt_setup.agirliklar(end+1) = str2double(get(handles.h_opt_w_capT, 'String'));
            end
            if get(handles.h_opt_cb_capR, 'Value') == 1
                opt_setup.degiskenler{end+1} = 'capR';
                opt_setup.lb(end+1) = str2double(get(handles.h_opt_lb_capR, 'String'));
                opt_setup.ub(end+1) = str2double(get(handles.h_opt_ub_capR, 'String'));
                opt_setup.agirliklar(end+1) = str2double(get(handles.h_opt_w_capR, 'String'));
            end
            
            opt_setup.nvars = length(opt_setup.degiskenler);
            if opt_setup.nvars == 0
                msgbox('Optimizasyon için en az bir değişken seçmelisiniz.', 'Hata', 'warn');
                return;
            end
            if any(opt_setup.lb >= opt_setup.ub)
                msgbox('Hata: Bir değişkenin Min. Değeri, Maks. Değerinden büyük veya eşit olamaz.', 'Hata', 'error');
                return;
            end
            if any(isnan(opt_setup.lb)) || any(isnan(opt_setup.ub)) || any(isnan(opt_setup.agirliklar))
                msgbox('Hata: Ağırlık/Sınır kutularında geçersiz (sayısal olmayan) değerler var.', 'Hata', 'error');
                return;
            end
            
            opt_setup.hedef_marj = str2double(get(handles.h_opt_hedef_marj, 'String'));
            if isnan(opt_setup.hedef_marj)
                opt_setup.hedef_marj = 3.0;
                set(handles.h_opt_hedef_marj, 'String', '3.0');
            end
            
        catch ME
            msgbox(sprintf('Optimizasyon ayarları okunurken hata: %s', ME.message), 'Hata');
            return;
        end
        
        kaydet_ve_hesapla_callback([],[]);
        h_wait = waitbar(0, 'Genetik Algoritma (Çok Değişkenli) çalışıyor...', 'Name', 'Gelişmiş Optimizasyon');
        fitnessfcn = @maliyet_fonksiyonu_MULTI;  
        nonlcon = @kisit_fonksiyonu_MULTI;       
        options = optimoptions('ga', 'Display', 'iter'); 
        
        try
            [x_sonuc, fval_sonuc] = ga(fitnessfcn, opt_setup.nvars, [], [], [], [], ...
                                      opt_setup.lb, opt_setup.ub, nonlcon, options);
            close(h_wait); 
            [c_son, ~] = kisit_fonksiyonu_MULTI(x_sonuc);
            bulunan_marj = opt_setup.hedef_marj - c_son;
            mesaj_detaylari = 'Optimizasyon tamamlandı!\n\n';
            for i = 1:opt_setup.nvars
                degisken_adi = opt_setup.degiskenler{i};
                bulunan_deger = x_sonuc(i);
                switch degisken_adi
                    case 'guc'
                        set(handles.h_verici_guc, 'String', num2str(bulunan_deger));
                        mesaj_detaylari = [mesaj_detaylari, sprintf('Min. Verici Gücü: %.3f W\n', bulunan_deger)];
                    case 'capT'
                        set(handles.h_verici_capT, 'String', num2str(bulunan_deger));
                        mesaj_detaylari = [mesaj_detaylari, sprintf('Min. Verici Çapı: %.3f m\n', bulunan_deger)];
                    case 'capR'
                        set(handles.h_alici_capR, 'String', num2str(bulunan_deger));
                        mesaj_detaylari = [mesaj_detaylari, sprintf('Min. Alıcı Çapı: %.3f m\n', bulunan_deger)];
                end
            end
            mesaj = sprintf([...
                '%s\n' ...
                'Hedef Marj (%s dB) için bulunan optimum maliyet: %.4f\n\n' ...
                'Bu değerlerle hesaplanan marj: %.2f dB'], ...
                mesaj_detaylari, num2str(opt_setup.hedef_marj), fval_sonuc, bulunan_marj);
            msgbox(mesaj, 'Optimizasyon Sonucu', 'help');
            kaydet_ve_hesapla_callback([],[]);
        catch ME
            close(h_wait);
            if contains(ME.identifier, 'gads:License')
                msgbox('Hata: Global Optimization Toolbox lisansı bulunamadı veya yüklü değil.', 'Hata', 'error');
            else
                msgbox(sprintf('Optimizasyon sırasında bir hata oluştu: %s', ME.message), 'Hata', 'error');
            end
        end
    
        function maliyet = maliyet_fonksiyonu_MULTI(x)
            maliyet = 0;
            for i = 1:opt_setup.nvars
                if (opt_setup.ub(i) - opt_setup.lb(i)) == 0
                    x_norm = 0;
                else
                    x_norm = (x(i) - opt_setup.lb(i)) / (opt_setup.ub(i) - opt_setup.lb(i));
                end
                maliyet = maliyet + opt_setup.agirliklar(i) * x_norm;
            end
        end
    
        function [c, ceq] = kisit_fonksiyonu_MULTI(x)
            v_temp = uyduVerileri.verici;
            a_temp = uyduVerileri.alici;
            k_temp = uyduVerileri.kayiplar;
            
            % GÜNCELLENDİ: Optimizasyon kısıtında yeni menzil hesaplama mantığı kullanılacak.
            phi_yer = uyduVerileri.sistem.yer_enlem;
            lambda_yer = uyduVerileri.sistem.yer_boylam;
            h_yer = uyduVerileri.sistem.yer_irtifa;
            phi_uydu = uyduVerileri.sistem.uydu_enlem;
            lambda_uydu = uyduVerileri.sistem.uydu_boylam;
            h_uydu = uyduVerileri.sistem.uydu_irtifa;
            
            % GÜNCELLENDİ: Maksimum irtifa yerine coğrafi irtifa kullanılacak.
            [X_yer, Y_yer, Z_yer] = geodetic_to_ecef(phi_yer, lambda_yer, h_yer);
            [X_uydu, Y_uydu, Z_uydu] = geodetic_to_ecef(phi_uydu, lambda_uydu, h_uydu);
            range_m = sqrt((X_uydu - X_yer)^2 + (Y_uydu - Y_yer)^2 + (Z_uydu - Z_yer)^2);
            d_km = range_m / 1000;
            
            for i = 1:opt_setup.nvars
                switch opt_setup.degiskenler{i}
                    case 'guc'
                        v_temp.guc = x(i);
                    case 'capT'
                        v_temp.capT = x(i);
                    case 'capR'
                        a_temp.capR = x(i);
                end
            end
            
            k_temp.fsl = 92.45 + 20*log10(d_km) + 20*log10(v_temp.frekans);
            try
                sonuc_temp = anlik_hesapla(v_temp, a_temp, k_temp, d_km);
                link_marjini = sonuc_temp.link_marjini;
            catch
                link_marjini = -999; 
            end
            c = opt_setup.hedef_marj - link_marjini; 
            ceq = []; 
        end
    end
    
    % --- YENİ WGS84 ECEF DÖNÜŞÜM FONKSİYONU (GÖRSELDEKİ TABLO) ---
    function [X, Y, Z] = geodetic_to_ecef(phi_deg, lambda_deg, h_m)
        
        % Adım 0: Defining Constants (WGS84)
        a = 6378137.0; % Yarı büyük eksen (Radius)
        f = 1/298.257223563; % Basıklık (Flattening)
        e2 = 2*f - f^2; % Basıklık Karesi (Eccentricity Squared)
        
        % Adım 1: Unit Conversion
        phi_rad = deg2rad(phi_deg); % Enlem (Latitude)
        lambda_rad = deg2rad(lambda_deg); % Boylam (Longitude)
        
        % Adım 2: Radius of Curvature (N) - Yerel Dikey Eğrilik Yarıçapı
        N_phi = a / sqrt(1 - e2 * (sin(phi_rad)^2));
        
        % Adım 3-5: Kartezyen (X, Y, Z) Koordinat Hesaplama
        
        % X Coordinate
        X = (N_phi + h_m) * cos(phi_rad) * cos(lambda_rad);
        
        % Y Coordinate
        Y = (N_phi + h_m) * cos(phi_rad) * sin(lambda_rad);
        
        % Z Coordinate
        Z = (N_phi * (1 - e2) + h_m) * sin(phi_rad);
    end
end
