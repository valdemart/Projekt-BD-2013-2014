using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WindowsFormsApplication1
{
    public abstract class IBaza
    {
        public abstract void polacz_z_baza();
        public abstract void rozlacz_z_baza();

        public abstract void dodaj_osobe(string imie, string nazwisko, char plec, int tel, string email, string adres);
        public abstract void usun_osobe(string imie, string nazwisko);
        public abstract void aktualizuj_osobe(string imie, string nazwisko, char plec, int tel, string email, string adres);

        public abstract void dodaj_pare_mloda(string imie_zony, string nazwisko_zony, string imie_meza, string nazwisko_meza);
        public abstract void usun_pare_mloda(string imie_zony, string nazwisko_zony, string imie_meza, string nazwisko_meza);
        public abstract void aktualizuj_pare_mloda(string imie_zony, string nazwisko_zony, string imie_meza, string nazwisko_meza, decimal budzet);

        public abstract void dodaj_wesele(string imie_zony, string nazwisko_zony, string imie_meza, string nazwisko_meza, DateTime data_wesela);
        public abstract void usun_wesele(string imie_zony, string nazwisko_zony, string imie_meza, string nazwisko_meza);
        public abstract void aktualizuj_wesele(string imie_zony, string nazwisko_zony, string imie_meza, string nazwisko_meza, DateTime data_wesela);

        public abstract void dodaj_goscia(string imie, string nazwisko, string opis_prezentu, int liczba_osob_towarzyszacych);
        public abstract void usun_goscia(string imie, string nazwisko);
        public abstract void aktualizuj_goscia(string imie, string nazwisko, string opis_prezentu, int liczba_osob_towarzyszacych);

        public abstract void dodaj_sale(string adres, int liczba_miejsc, decimal cena_za_osobe, string ok_imie, string ok_nazwisko, string link);
        public abstract void usun_sale(string adres);
        public abstract void aktualizuj_sale(string adres, int liczba_miejsc, decimal cena_za_osobe, string ok_imie, string ok_nazwisko, string link);

        public abstract void dodaj_rezerwacje_sali(string adres_sali, DateTime data);
        public abstract void usun_rezerwacje_sali(string adres_sali, DateTime data);
        public abstract void aktualizuj_rezerwacje_sali(string adres_sali, DateTime data);

        public abstract void dodaj_orkiestre(string nazwa, int ilosc_osob, int telefon, decimal cena, string link);
        public abstract void usun_orkiestre(string nazwa);
        public abstract void aktualizuj_orkiestre(string nazwa, int ilosc_osob, int telefon, decimal cena, string link);

        public abstract void dodaj_fk(string imie, string nazwisko, bool czy_fotograf, bool czy_kamerzysta, decimal stawka, string link);
        public abstract void usun_fk(string imie, string nazwisko);
        public abstract void aktualizuj_fk(string imie, string nazwisko, bool czy_fotograf, bool czy_kamerzysta, decimal stawka, string link);

        public abstract void pobierz_dane(Form1 okno);
    }
}
