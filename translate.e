-- translate.e 
-- 1= Deutsch 2= English 3=bahasa indonesia
atom defaultlang=1
atom outlang = defaultlang

sequence transtab={
            {"RTU Parameter","RTU parameters","",""},
            {"Analog","","",""},
            {"Potentiometer","","Potensiometer",""},
            {"Fotowiderstand","Photoresistor","fotoresistor",""},
            {"Buttons","","Tombol",""},
            {"Led An","Led ON","Led ON",""},
            {"Led Aus","Led OFF","Led OFF",""},
            {"Modbus einstellungen","Modbus settings","",""},
            {"Verbinden","Connect","Menghubungkan",""},
            {"Fehler:","Error:","Kesalahan:",""},
            {"getrennt","disconnected","terputus",""},
            {" ist keine g�ltige Slave Id"," is not a valid slave Id","bukan Id budak yang valid",""},
            {"Trennen","Disconnect","Putuskan sambungan",""},
            {"Verbunden ","Connected ","Terhubung ",""},
            {"Verbindung fehlgeschlagen","Connection failed","Koneksi gagal",""},
            {"Verbindungsabbruch.\n Neu verbinden?","Connection aborted.\n Reconnect?","Koneksi dibatalkan.\n Hubungkan kembali?",""},
            {"Fehlerhaft :","Erroneous :","Rusak:",""},
            {" Gesamt :"," Total :"," Total :",""},
            {"Suche Com Ports","Search Com Ports","Cari Pelabuhan Com",""},
            {"Suche Com Ports beendet","Search Com Ports finished","Pencarian Port Com selesai",""},
            {"Beenden","Quit","Keluar",""},
            {"Sind sie sicher?","Are you sure","Apakah mereka aman?",""},
            {"Verbindungsfehler","Connection error","Kesalahan koneksi",""},
            {"","",""},
            {"","",""},
            {"","",""},
            {"","",""},
            {"","",""},
            {"","",""},
            {"","",""},
            {"","",""},
            {"","",""}
         }




global function xlt(sequence inseq)
sequence outseq=inseq
    for i=1 to length(transtab)  do
        if equal(transtab[i][defaultlang],inseq) then
            try
                outseq=transtab[i][outlang]
            catch e
                outseq=transtab[i][defaultlang]
            end try
        end if
    end for
if not length(outseq) then
    return inseq
else
    return outseq
end if
end function
