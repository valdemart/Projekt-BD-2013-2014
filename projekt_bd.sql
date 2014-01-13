create database wesela
go

use wesela
go

--############################################################################################
--############################################################################################
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

create procedure dodaj_osobe
	@imie varchar(20),
	@nazwisko varchar(100),
	@plec char,
	@tel int,
	@email varchar(250),
	@adres varchar(100)
as
begin
	if exists (select * from osoby where imie=@imie and nazwisko=@nazwisko)
	begin
		raiserror('Wskazana osoba ju¿ istnieje w bazie', 16, 1);
		return
	end;

	declare @id_osoby int
	set @id_osoby = 1
	if exists(select max(id_osoby) from osoby)
	begin
		set @id_osoby = (select max(id_osoby) from osoby)+@id_osoby;
	end;

	insert into osoby values(@id_osoby, @imie, @nazwisko, @plec, @tel, @email, @adres)
end;
go

create procedure usun_osobe
	@imie varchar(20),
	@nazwisko varchar(100)
as
begin
	if not exists (select * from osoby where imie=@imie and nazwisko=@nazwisko)
	begin
		raiserror('Wskazana osoba nie istnieje w bazie', 16, 1);
		return
	end;

	delete from osoby where imie=@imie and nazwisko=@nazwisko
end;
go

--############################################################################################
--############################################################################################
create table pary_mlode (
	id_pary int not null primary key,
	id_zony int not null foreign key references osoby(id_osoby) on delete cascade,
	id_meza int not null foreign key references osoby(id_osoby) on delete cascade,
	budzet decimal
);
go

create procedure dodaj_pare_mloda
	@imie_zony varchar(20),
	@nazwisko_zony varchar(100),
	@imie_meza varchar(20),
	@nazwisko_meza varchar(100)
as
begin
	if not exists (select * from osoby where imie=@imie_zony and nazwisko=@nazwisko_zony)
	begin
		raiserror('Brak danych ¿ony w bazie', 16, 1);
		return
	end;
	if not exists (select * from osoby where imie=@imie_meza and nazwisko=@nazwisko_meza)
	begin
		raiserror('Brak danych mê¿a w bazie', 16, 1);
		return
	end;

	declare @id_pary int
	set @id_pary = 1
	if exists (select * from pary_mlode)
	begin
		set @id_pary = (select max(id_pary) from pary_mlode)+@id_pary;
	end;
	
	insert into pary_mlode values (@id_pary, (select id_osoby from osoby where imie=@imie_zony and nazwisko=@nazwisko_zony), (select id_osoby from osoby where imie=@imie_meza and nazwisko=@nazwisko_meza))
end;
go

create procedure usun_pare_mloda
	@imie_zony varchar(20),
	@nazwisko_zony varchar(100),
	@imie_meza varchar(20),
	@nazwisko_meza varchar(100)
as
begin
	if not exists (select * from osoby where imie=@imie_zony and nazwisko=@nazwisko_zony)
	begin
		raiserror('Brak danych ¿ony w bazie', 16, 1);
		return
	end;
	if not exists (select * from osoby where imie=@imie_meza and nazwisko=@nazwisko_meza)
	begin
		raiserror('Brak danych mê¿a w bazie', 16, 1);
		return
	end;

	declare @id_zony int, @id_meza int
	set @id_zony = (select id_osoby from osoby where imie=@imie_zony and nazwisko=@nazwisko_zony);
	set @id_meza = (select id_osoby from osoby where imie=@imie_meza and nazwisko=@nazwisko_meza);
	if not exists (select * from pary_mlode where id_zony=@id_zony and id_meza=@id_meza)
	begin
		raiserror('Wskazane osoby nie s¹ zarejestrowane jako para m³oda', 16, 1);
		return
	end;

	delete from pary_mlode where id_zony=@id_zony and id_meza=@id_meza
end;
go

--############################################################################################
--############################################################################################
create table sale (
	id_sali int not null primary key,
	liczba_miejsc int not null,
	adres varchar(100) not null,
	cena_za_osobe decimal not null,
	osoba_kontaktowa int not null foreign key references osoby(id_osoby) on delete cascade,
	link varchar(250)
);
go

create procedure dodaj_sale
	@adres varchar(100),
	@liczba_miejsc int,
	@cena_za_osobe decimal,
	@ok_imie varchar(20),
	@ok_nazwisko varchar(100),
	@link varchar(250)
as
begin
	if exists (select * from sale where adres=@adres)
	begin
		raiserror('Sala o podanym adresie ju¿ istnieje w bazie', 16, 1);
		return
	end;
	if not exists (select * from osoby where imie=@ok_imie and nazwisko=@ok_nazwisko)
	begin
		raiserror('Osoba kontaktowa nie istnieje w bazie', 16, 1);
		return
	end;

	declare @id_sali int
	set @id_sali = 1
	if exists (select * from sale)
	begin
		set @id_sali = (select max(id_sali) from sale)+@id_sali
	end;

	insert into sale values(@id_sali, @liczba_miejsc, @adres, @cena_za_osobe, (select id_osoby from osoby where imie=@ok_imie and nazwisko=@ok_nazwisko), @link)
end;
go

create procedure usun_sale
	@adres varchar(100)
as
begin
	if not exists (select * from sale where adres=@adres)
	begin
		raiserror('Sala o podanym adresie nie istnieje w bazie', 16, 1);
		return
	end;

	delete from sale where adres=@adres
end;
go

--############################################################################################
--############################################################################################
create table rezerwacje_sal (
	id_rezerwacji_sali int not null primary key,
	data_rezerwacji date,
	id_sali int not null foreign key references sale(id_sali) on delete cascade
);
go

create trigger test_wolna_sala
on rezerwacje_sal
after insert
as
if exists (select * from rezerwacje_sal as s
		   join inserted as i on s.id_sali=i.id_sali
		   where s.data_rezerwacji=i.data_rezerwacji)
begin
	raiserror('Sala jest ju¿ zajêta w tym dniu', 16, 1);
	rollback transaction;
	return
end;
go

create procedure dodaj_rezerwacje_sali
	@adres_sali varchar(100),
	@data date
as
begin
	if not exists (select * from sale where adres=@adres_sali)
	begin
		raiserror('Sala o podanym adresie nie istnieje w bazie', 16, 1);
		return
	end;

	declare @id_rezerwacji int
	set @id_rezerwacji = 1
	if exists (select * from rezerwacje_sal)
	begin
		set @id_rezerwacji = (select max(id_rezerwacji_sali) from rezerwacje_sal)+@id_rezerwacji;
	end;

	insert into rezerwacje_sal values(@id_rezerwacji, @data, (select id_sali from sale where adres=@adres_sali))
end;
go

create procedure usun_rezerwacje_sali
	@adres varchar(100),
	@data date
as
begin
	if not exists (select * from sale where adres=@adres)
	begin
		raiserror('Sala o podanym adresie nie istnieje w bazie', 16, 1);
		return
	end;
	
	declare @id_sali int
	set @id_sali = (select id_sali from sale where adres=@adres);

	if not exists (select * from rezerwacje_sal where id_sali=@id_sali and data_rezerwacji=@data)
	begin
		raiserror('Wskazana sala nie jest zarezerwowana w podanym terminie', 16, 1);
		return
	end;

	delete from rezerwacje_sal where id_sali=@id_sali and data_rezerwacji=@data
end;
go

--############################################################################################
--############################################################################################
create table orkiestry (
	id_orkiestry int not null primary key,
	nazwa varchar(20) not null,
	ilosc_osob_w_zespole int not null,
	telefon int not null,
	cena decimal,
	link varchar(250)
);
go

create procedure dodaj_orkiestre
	@nazwa varchar(20),
	@ilosc_osob int,
	@telefon int,
	@cena decimal,
	@link varchar(250)
as
begin
	if exists (select * from orkiestry where nazwa=@nazwa)
	begin
		raiserror('Orkiestra o podanej nazwie ju¿ istnieje w bazie', 16, 1);
		return
	end;

	declare @id_orkiestry int
	set @id_orkiestry = 1;
	if exists (select * from orkiestry)
	begin
		set @id_orkiestry = (select max(id_orkiestry) from orkiestry)+@id_orkiestry;
	end;

	insert into orkiestry values(@id_orkiestry, @nazwa, @ilosc_osob, @telefon, @cena, @link)
end;
go

create procedure usun_orkiestre
	@nazwa varchar(20)
as
begin
	if not exists (select * from orkiestry where nazwa=@nazwa)
	begin
		raiserror('Orkiestra o podanej nazwie nie istnieje w bazie', 16, 1);
		return
	end;

	delete from orkiestry where nazwa=@nazwa
end;
go

--############################################################################################
--############################################################################################
create table fotografowie_i_kamerzysci (
	id_fotografa int not null primary key,
	dane int not null foreign key references osoby(id_osoby) on delete cascade,
	czy_fotograf int not null, --1 - jest fotografem, 0 - nie jest
	czy_kamerzysta int not null, --1 - jest kamerzysta, 0 - nie jest
	stawka decimal,
	link varchar(250)
);
go

create procedure dodaj_fk
	@imie varchar(20),
	@nazwisko varchar(100),
	@czy_fotograf int,
	@czy_kamerzysta int,
	@stawka decimal,
	@link varchar(250)
as
begin
	if not exists (select * from osoby where imie=@imie and nazwisko=@nazwisko)
	begin
		raiserror('Wskazana osoba nie istnieje w bazie', 16, 1);
		return
	end;

	declare @id_osoby int
	set @id_osoby = (select id_osoby from osoby where imie=@imie and nazwisko=@nazwisko);

	if exists (select * from fotografowie_i_kamerzysci where dane=@id_osoby)
	begin
		raiserror('Wskazana osoba znajduje siê ju¿ na liœcie fotografów i kamerzystów', 16, 1);
		return
	end;

	declare @id_fk int
	set @id_fk = 1
	if exists (select * from fotografowie_i_kamerzysci)
	begin
		set @id_fk = (select max(id_fotografa) from fotografowie_i_kamerzysci)+@id_fk;
	end;

	insert into fotografowie_i_kamerzysci values(@id_fk, @id_osoby, @czy_fotograf, @czy_kamerzysta, @stawka, @link)
end;
go

create procedure usun_fk
	@imie varchar(20),
	@nazwisko varchar(100)
as
begin
	if not exists (select * from osoby where imie=@imie and nazwisko=@nazwisko)
	begin
		raiserror('Wskazana osoba nie istnieje w bazie', 16, 1);
		return
	end;

	declare @id_osoby int
	set @id_osoby = (select id_osoby from osoby where imie=@imie and nazwisko=@nazwisko);

	if not exists (select * from fotografowie_i_kamerzysci where dane=@id_osoby)
	begin
		raiserror('Wskazana osoba nie znajduje siê na liœcie fotografów i kamerzystów', 16, 1);
		return
	end;

	delete from fotografowie_i_kamerzysci where dane=@id_osoby
end;
go

--############################################################################################
--############################################################################################
create table rachunki (
	id_rachunku int not null primary key,
	id_wesela int foreign key references wesela(id_wesela),
	nr_konta varchar(26) not null,
	kwota decimal not null,
	termin_zaplaty date not null,
	data_wplaty date
);
go

create procedure dodaj_rachunek
	@id_wesela int,
	@nr_konta varchar(26),
	@kwota decimal,
	@termin_zaplaty date
as
begin
	if exists (select * from rachunki where id_wesela=@id_wesela)
	begin
		raiserror('Wystawiono ju¿ rachunek za wskazane wesele', 16, 1);
		return
	end;

	declare @id_rachunku int
	set @id_rachunku = 1
	if exists (select * from rachunki)
	begin
		set @id_rachunku = (select max(id_rachunku) from rachunki)+@id_rachunku;
	end;

	insert into rachunki values(@id_rachunku, @id_wesela, @nr_konta, @kwota, @termin_zaplaty, null)
end;
go

create procedure usun_rachunek
	@id_wesela int
as
begin
	if not exists (select * from rachunki where id_wesela=@id_wesela)
	begin
		raiserror('Nie wystawiono rachunku za wskazane wesele', 16, 1);
		return
	end;

	delete from rachunki where id_wesela=@id_wesela
end;
go

--############################################################################################
--############################################################################################
create table goscie (
	id_goscia int not null primary key,
	dane int not null foreign key references osoby(id_osoby) on delete cascade,	
	liczba_osob_towarzyszacych int,
	opis_prezentu varchar(5000) not null
);
go

create procedure dodaj_goscia
	@imie varchar(20),
	@nazwisko varchar(100),
	@opis_prezentu varchar(5000),
	@liczba_osob_towarzyszacych int
as
begin
	if not exists (select * from osoby where imie=@imie and nazwisko=@nazwisko)
	begin
		raiserror('Wskazana osoba nie istnieje w bazie', 16, 1);
		return
	end;

	declare @id_osoby int
	set @id_osoby = (select id_osoby from osoby where imie=@imie and nazwisko=@nazwisko)

	if exists (select * from goscie where dane=@id_osoby)
	begin
		raiserror('Goœæ jest ju¿ na liœcie', 16, 1);
		return
	end;

	declare @id_goscia int
	set @id_goscia = 1
	if exists (select * from goscie)
	begin
		set @id_goscia = (select max(id_goscia) from goscie)+@id_goscia;
	end;
	
	insert into goscie values(@id_goscia, @id_osoby, @liczba_osob_towarzyszacych, @opis_prezentu)
end;
go

create procedure usun_goscia
	@imie varchar(20),
	@nazwisko varchar(100)
as
begin
	if not exists (select * from osoby where imie=@imie and nazwisko=@nazwisko)
	begin
		raiserror('Wskazana osoba nie istnieje w bazie', 16, 1);
		return
	end;

	declare @id_osoby int
	set @id_osoby = (select id_osoby from osoby where imie=@imie and nazwisko=@nazwisko)

	if not exists (select * from goscie where dane=@id_osoby)
	begin
		raiserror('Wskazana osoba nie istnieje w bazie goœci', 16, 1);
		return
	end;

	delete from goscie where dane=@id_osoby
end;
go

--############################################################################################
--############################################################################################
create table listy_gosci (
	id_listy int not null primary key,
	nazwa_tabeli varchar(100) not null
);
go

--create table lista_goscixxxx (
--	id_goscia int not null foreign key references goscie(id_goscia) on delete cascade
--);
--go

--create trigger test_czy_na_liscie
--on lista_goscixxxx
--after insert
--as
--if (select count (*) from lista_goscixxxx as lg, inserted as i
   --where lg.id=i.id)>1
--begin
--	raiserror('Goœæ ju¿ jest na liœcie', 16, 1);
--	rollback transaction;
--	return
--end;
--go

create procedure dodaj_liste_gosci
	@id_wesela int
as
begin
	declare @sql varchar(2000), @tabela sysname
	set @tabela = 'lista_gosci'+cast(@id_wesela as varchar(20))
	set @sql = 'create table '+ quotename(@tabela) +' (id_goscia int not null foreign key references goscie(id_goscia) on delete cascade)';
	execute (@sql);
	set @sql = 'create trigger test_czy_na_liscie on '+quotename(@tabela)+' after insert as if (select count (*) from '+quotename(@tabela)+' as lg, inserted as i where lg.id=i.id)>1 begin raiserror(''Goœæ ju¿ jest na liœcie'', 16, 1); rollback transaction; return end;'
	execute (@sql);
end;
go

create procedure usun_liste_gosci
	@id_wesela int
as
begin
	declare @sql varchar(2000), @tabela sysname
	set @tabela = 'lista_gosci'+cast(@id_wesela as varchar(20))
	set @sql = 'delete from '+ quotename(@tabela)
	execute (@sql);
	set @sql = 'drop table '+quotename(@tabela)
	execute (@sql);
end;
go

--############################################################################################
--############################################################################################
create table wesela (
	id_wesela int not null primary key,
	_data datetime not null,
	id_pary int not null foreign key references pary_mlode(id_pary) on delete cascade,
	id_listy_gosci int not null foreign key references listy_gosci(id_listy) on delete cascade,
	id_rezerwacji_sali int foreign key references rezerwacje_sal(id_rezerwacji_sali),
	id_fotografa int foreign key references fotografowie_i_kamerzysci(id_fotografa),
	id_orkiestry int foreign key references orkiestry(id_orkiestry),
	id_rachunku int foreign key references rachunki(id_rachunku)
);
go

create procedure dodaj_wesele
	@imie_zony varchar(20),
	@nazwisko_zony varchar(100),
	@imie_meza varchar(20),
	@nazwisko_meza varchar(100),
	@data_wesela datetime
as
begin
	if not exists (select * from osoby where imie=@imie_zony and nazwisko=@nazwisko_zony)
	begin
		raiserror('Brak danych ¿ony w bazie', 16, 1);
		return
	end;
	if not exists (select * from osoby where imie=@imie_meza and nazwisko=@nazwisko_meza)
	begin
		raiserror('Brak danych mê¿a w bazie', 16, 1);
		return
	end;
end;
go
