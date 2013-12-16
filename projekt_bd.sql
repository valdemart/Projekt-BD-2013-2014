create database wesela
go

use wesela
go

create table osoby (
	id_osoby int not null primary key,
	imie varchar(20) not null,
	nazwisko varchar(100) not null,
	plec char not null,
	tel int,
	email varchar(250),
	adres varchar(100)
);
go

create table pary_mlode (
	id_pary int not null primary key,
	id_zony int not null foreign key references osoby(id_osoby),
	id_meza int not null foreign key references osoby(id_osoby),
	budzet decimal
);
go

create table prezenty (
	id_prezentu int not null primary key,
	opis_prezentu varchar(5000) not null
);
go

create table sale (
	id_sali int not null primary key,
	liczba_miejsc int not null,
	adres varchar(100) not null,
	cena_za_osobe decimal not null,
	osoba_kontaktowa int not null foreign key references osoby(id_osoby),
	link varchar(250)
);
go

create table orkiestry (
	id_orkiestry int not null primary key,
	nazwa varchar(20) not null,
	ilosc_osob_w_zespole int not null,
	telefon int not null,
	cena decimal,
	link varchar(250)
);
go

create table fotografowie_i_kamerzysci (
	id_fotografa int not null primary key references osoby(id_osoby),
	czy_fotograf int not null, --1 - jest fotografem, 0 - nie jest
	czy_kamerzysta int not null, --1 - jest kamerzysta, 0 - nie jest
	stawka_za_h decimal,
	link varchar(250)
);
go

create table rachunki (
	id_rachunku int not null primary key,
	nr_konta varchar(26) not null,
	kwota decimal not null,
	termin_zaplaty datetime not null,
	data_wplaty datetime
);
go

create table wesela (
	id_wesela int not null primary key,
	_data datetime not null,
	id_pary int not null foreign key references pary_mlode(id_pary),
	liczba_gosci int not null,
	id_sali int foreign key references sale(id_sali),
	id_fotografa int foreign key references fotografowie_i_kamerzysci(id_fotografa),
	id_orkiestry int foreign key references orkiestry(id_orkiestry),
	id_rachunku int foreign key references rachunki(id_rachunku)
);
go

create table goscie (
	id_goscia int not null primary key,
	id_prezentu int foreign key references prezenty(id_prezentu),
	liczba_osob_towarzyszacych int,
	id_wesela int not null foreign key references wesela(id_wesela)
);
go
