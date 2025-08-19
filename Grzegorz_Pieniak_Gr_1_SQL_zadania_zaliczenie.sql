--Zad. 1
--Nale�y wybra� produkty sprzedawane w pude�kach (ang. box), gdzie zapas magazynowy jest w zakresie od 20 do 35, 
--a identyfikator kategorii produktu to 2 lub 3, u�o�one w kolejno�ci od najdro�szych.
--Wy�wietl nazwy produkt�w oraz wszystkie szczeg�y zwi�zane z podanymi warunkami.
-----
select * from Products --wy�wietla wszystko z Products 
where (QuantityPerUnit like '%box%') and (UnitsInStock between 20 and 35) and (CategoryID in ('2', '3'))
order by UnitPrice desc
-----
select ProductName, CategoryID, UnitsInStock, QuantityPerUnit from Products --wy�wietla tylko 3 kolumny z Products 
where (QuantityPerUnit like '%box%') and (UnitsInStock between 20 and 35) and (CategoryID in ('2', '3'))
order by UnitPrice desc
-----wniosek tylko 3 produkty spe�niaj� powy�sze kryteria.

--Zad. 2
--Nale�y wybra� zam�wienia, gdzie kraj dostawy to Francja lub Niemcy, nazwa miasta zaczyna si� na liter� B, K lub P, 
--zam�wienie zosta�o dostarczone, w kolejno�ci sk�adania zam�wie�.
--Wy�wietl numery zam�wie� oraz wszystkie szczeg�y zwi�zane z podanymi warunkami.
-----
select orderid, shipcountry, shipcity, orderdate, shippeddate from Orders
where (ShipCountry in ('Germany', 'France')) and (shipcity like 'B%' or shipcity like 'K%' or shipcity like 'P%') 
and (ShippedDate is not null)
order by OrderDate asc
--- wniosek 34 zam�wienia spe�niaj� powy�sze kryteria.

-----
--Zad. 3
--Podaj klient�w, kt�rzy z�o�yli zam�wienia w pierwszych 5 dniach ka�dego miesi�ca.
-----
select CustomerID --, OrderDate 
from orders where (day(OrderDate) between 1 and 5) 
 group by CustomerID
order by CustomerID
-----wniosek jest 63 klient�w, kt�rzy z�o�yli zam�wienia w pierwszych 5 dniach ka�dego miesi�ca.
-- niestety po d�u�szym czasie niepowodze� skorzysta�em z chatgpt. Proste zadanie, ale mnie d�ugo si� zmaga�em z u�yciem DATEADD co okaza�o si� pora�k�.

--Zad. 4
--Jaki jest �redni czas (w dniach) realizacji zam�wienia (od z�o�enia do wys�ania) przez poszczeg�lnych pracownik�w.
--Wy�wietl dwie kolumny: identyfikator pracownika, �redni czas dostawy.
--�rednia powinna by� przedstawiona jako u�amek (liczba z przecinkiem).
-----
select EmployeeID, avg(cast(ShippeDdate - OrderDate as float)) as '�rednia_czas_dostawy' from orders 
where ShippedDate is not null group by EmployeeID order by �rednia_czas_dostawy asc
----- wniosek: 9 pracownik�w ma �rednie czasy realizacji zam�wie� od 7 do 10 dni, nr.5 jest najlepszym pracownikiem.

--Zad. 5
--Jaka jest liczba pracownik�w urodzonych w poszczeg�lnych latach.
--Wy�wietl dwie kolumny: rok urodzenia, liczba pracownik�w.
--- (dodaje tylko po to by wy�wietli� co jest w orders) 
-----
select year(BirthDate) as 'rok urodzenia', count(*) as 'liczba_pracownikow' 
from Employees 
group by year(BirthDate)
----- wniosek: jest 9 pracownik�w, z czego 2 jest z rocznika 1963.

--Zad. 6
--Poka� pracownik�w, kt�rzy w III kwartale 1996 roku przyj�li
--wi�cej ni� 5 zam�wie�.
--Wy�wietl identyfikator pracownika, liczb� zam�wie�.
----
select Employeeid, count(OrderID) as 'Liczba_Zamowien' from Orders --bez count() nie zadzia�a
where (year(OrderDate) = 1996) and (month(OrderDate) between 07 and 09) --pytanie czy to jest dobrze? czy da si� to zapisa� kr�cej/inaczej na z u�yciem Dateadd()?
group by Employeeid
having count(OrderID) > 5 
order by Employeeid
---- wniosek: pracownicy 5 i 9 musz� mie� mniej ni� 5 zam�wie� we wskazanym przedziale czasowym.

--Zad. 7
--Ile zam�wie� zrealizowali poszczeg�lni przewo�nicy i ile ��cznie za nie dostali w roku 1997.
--Wy�wietl trzy kolumny: identyfikator przewo�nika (ShipVia), liczba zam�wie�, koszt przewozu (Freight)
----
select ShipVia as 'identyfikator przewo�nika', count(OrderID) as 'liczba zam�wie�', sum(Freight) as 'koszt_przewozu' from Orders
where year(ShippedDate) = 1997
group by ShipVia
order by ShipVia
----wniosek: 3 przewo�nik�w zrealizowa�o zam�wienia w kolejno�ci 1 - 130, 2 - 143, 3 - 125

--Zad. 8
--Podaj klient�w (z nazwy), kt�rzy w 1997 roku z�o�yli przynajmniej 3 zam�wienia na produkty w s�oikach.
--Nazwy kolumn w kolejno�ci NAZWA_KLIENTA, LICZBA_ZAM
--- wersja rozwi�zania z uzyciem join ----------
select o.CustomerID as 'NAZWA_KLIENTA', count(o.OrderID) as 'LICZBA_ZAM' from Orders o 
JOIN [Order Details] od on od.OrderID = o.OrderID 
JOIN Products p on od.ProductId = p.ProductId 
where year(o.OrderDate) = 1997 and p.QuantityPerUnit like '%jar%'
group by o.CustomerID
having count(o.OrderID) >= 3
	--- wniosek: 6 klient�w w roku 1997 zam�wi�o przynajmniej 3 s�oiki na zam�wienie.
	-----------------------------
-----wersja rozwi�zania bez join-------
select O.CustomerID as 'NAZWA_KLIENTA', Count(O.OrderID) as 'LICZBA_ZAM'
from Orders O where year(O.OrderDate) = 1997 and
O.OrderID in
	(select OD.OrderID from [Order Details] OD where OD.ProductId in
		(select P.ProductId from Products P where P.QuantityPerUnit like '%jar%'))
group by o.CustomerID
having count(o.OrderID) >= 3
--- wniosek: 6 klient�w w roku 1997 zam�wi�o przynajmniej 3 s�oiki na zam�wienie
--- jest drobna r�nica w wynikach, wersja bez join obcina o jedno zam�wienie, ale nie wiadomo dlaczego tak si� dzieje.

--Zad. 9
--Znajd� wszystkich klient�w pochodz�cych z Niemiec, kt�rych ��czna warto�� zakupionego towaru jest wi�ksza ni� 5000.
--Posortuj list� alfabetycznie wed�ug klient�w.
--Wy�wietl nazwy kolumn w kolejno�ci: NAZWA_KLIENTA, WARTO��_ZAM
----- 
select cus.CustomerID as 'NAZWA_KLIENTA', sum(od.UnitPrice * od.Quantity) as 'WARTO��_ZAM' , cus.Country
from [Order Details] od join Orders ord on od.OrderID = ord.OrderID join Customers cus on ord.CustomerID = cus.CustomerID
where cus.Country = 'Germany'
group by cus.CustomerID, cus.Country
having sum(od.UnitPrice * od.Quantity) > 5000 
order by 'WARTO��_ZAM' desc
---- wniosek: tylko 7 klient�w z Niemiec ma zam�wienia > 5000.

--Zad. 10
--Poda� pracownik�w oraz liczb� zam�wie� zrealizowanych w terminie, w latach 1997-1998
--Dane wy�wietl w kolejno�ci od najwi�kszej liczby zam�wie�.
--Nazwy kolumn w kolejno�ci IMIE, NAZWISKO, LICZBA_ZAM
-----------
select emp.FirstName, emp.LastName, count(ord.OrderID) as 'LICZBA_ZAM', year(ord.ShippedDate) as 'Rok' from Orders ord 
join Employees emp on ord.EmployeeID=emp.EmployeeID
where year(ord.ShippedDate) between 1997 and 1998
group by emp.FirstName, emp.LastName,  year(ord.ShippedDate)
order by count(ord.OrderID) desc
------ wniosek: 18 pracownik�w ma zrealizowane zam�wienia w 1997-1998.

--Zad. 11   
-- Znajd� klienta, kt�ry nigdy niczego nie kupi�, sprawdzaj�c identyfikator klienta w tabeli zam�wie�. 
--- sprawdzenie:
select CustomerID from Customers
select CustomerID from Orders group by CustomerID
-- na podstawie r�nicy wynik�w w powy�szych 2 selectach stwierdzono, �e s� klienci, kt�rzy nie figuruj� w tabeli Orders, wi�c niczego nie zam�wili,
-- i trzeba znale��, kt�rzy to s�. Powinno by� 2 klient�w, poniewa� selecty zwracaj� Customers=91 i Orders=89
select  cus.CustomerID as 'Customers.CustomerID', cus.CompanyName as 'Customers.CompanyName', ord.CustomerID as 'Orders.CustomerID'
from Orders ord right join Customers cus on ord.CustomerID = cus.CustomerID 
where ord.OrderID IS NULL
-- wniosek: zastosowano right join, poniewa� wa�na jest r�nica mi�dzy tabelami, kt�ra wype�ania si� 'NULL-ami
-- w tabeli Orders jest 2 klient�w o nazwie Fissa i Paris bez realizowanych zam�wie�.

---- rozwi�zanie numer 2 (ale to jest '�ywcem' to samo co w przyk�adach, wi�c jest troch� dziwnie to podawa� jako rozwi�zanie - ??, 
-- ale dobrze zna� takie rozwi�zanie).
SELECT customerid, companyName FROM  customers
WHERE not EXISTS(SELECT orderid FROM  orders WHERE orders.customerid = customers.customerid)
----

--Zad. 12
--Wy�wietl informacje o produktach, gdzie rabat dla kategorii:
--Condiments wynosi 5%,
--Seafood wynosi 8%,
--Produce wynosi 15%,
--a dla pozosta�ych kategorii wynosi 4%
select * from Products

select cat.CategoryID, pro.ProductName, cat.CategoryName, case
when cat.CategoryID = 2 then pro.UnitPrice * 0.05
when cat.CategoryID = 8 then pro.UnitPrice * 0.08
when cat.CategoryID = 7 then pro.UnitPrice * 0.15
else pro.UnitPrice * 0.04
end AS 'Wysoko��_Rabatu'
from Categories cat
join Products pro on cat.CategoryID = pro.CategoryID
join [Order Details] od on pro.ProductID = od.ProductID
GROUP BY  cat.CategoryID, pro.ProductName, cat.CategoryName, pro.UnitPrice
ORDER BY cat.CategoryName
-- to zrobi�em w 100% samodzielnie!!

--Wy�wietl kolumny w kolejno�ci:
--kategoria,
--nazwa produktu,
--cena przed rabatem (UnitPrice),
--rabat w procentach (4, 5, 8 lub 15%),
--cena po rabacie (cena wyliczona).

select  cat.CategoryID, pro.ProductName, pro.UnitPrice, case
when cat.CategoryID = 2 then '5%'
when cat.CategoryID = 8 then '8%'
when cat.CategoryID = 7 then '15%'
else '4%'
end AS 'Rabat_w_%',
case
when cat.CategoryID = 2 then pro.UnitPrice - (pro.UnitPrice * 0.05)
when cat.CategoryID = 8 then pro.UnitPrice - (pro.UnitPrice * 0.08)
when cat.CategoryID = 7 then pro.UnitPrice - (pro.UnitPrice * 0.15)
else pro.UnitPrice - (pro.UnitPrice * 0.04)
end AS 'Cena_po_Rabacie'
from Categories cat 
join Products pro on cat.CategoryID = pro.CategoryID
join [Order Details] od on pro.ProductID = od.ProductID
GROUP BY  cat.CategoryID, pro.ProductName, pro.UnitPrice
ORDER BY pro.ProductName

--Wyja�nienie:
--*Cena przed rabatem to warto�� UnitPrice,
--*Cena po rabacie to warto�� UnitPrice obni�ona o warto�� 4, 5, 8 lub 15%   dla odpowiedniej kategorii 
--*- trzeba napisa� odpowiednie dzia�anie, aby cena po rabacie zosta�a wyliczona,
--*Rabat w procentach to odpowiednio 4, 5, 8 lub 15%.

--Zad. 13
--Wy�wietl (z nazwy) produkty niewycofane, gdy ich maksymalne ceny,
--po kt�rych zosta�y sprzedane s� r�wne przynajmniej 40$
--oraz produkty wycofane, gdy ich maksymalne ceny, po kt�rych zosta�y sprzedane s� wi�ksze ni� 25$.
--Posortuj wed�ug informacji o wycofaniu i cen malej�co.

select pro.ProductName as 'Nazwa_Produktu', pro.Discontinued as 'Informacja_o_Wycofaniu', max(ode.UnitPrice) as 'Cena_Waksymalna'
from Products pro
JOIN [Order Details] ode on pro.ProductID = ode.ProductID
where (pro.Discontinued = 1 and ode.UnitPrice >= 25) or (pro.Discontinued = 0 and ode.UnitPrice >= 40)
group by pro.Discontinued, pro.ProductName
order by 'Informacja_o_Wycofaniu' desc, 'Cena_Waksymalna' desc
-- wniosek: w sumie 15 produkt�w, z czego 5 jest wycofanych i 10 jest dopuszczonych do obrotu.

--Wy�wietl trzy kolumny:
--1) nazwa produktu
--2) informacja o wycofaniu
--3) cena maksymalna

--Wyja�nienie:
--*Discontinued z tabeli Products - informacja o wycofaniu - warto�� 0 lub 1
--*maksymalne ceny, po kt�rych zosta�y sprzedane trzeba wybra� z tabeli Orders Details,
--gdy� tylko tam s� r�ne ceny dla danego produktu.
--W tabeli Products zawsze jest jedna cena dla danego produktu.

--Zad. 14
--Podaj nazwy produkt�w, kt�re nie by�y sprzedawane latem (od czerwca do sierpnia).
--====
select pro.ProductName from Products pro join [Order Details] ode on ode.ProductID = pro.ProductID join Orders ord on ord.OrderID = ode.OrderID 
where month(ord.ShippedDate) between 06 and 08 --and (ord.ShippedDate is not null) --<-- bez "not null" pokazuje tyle samo 72 pozycji
group by pro.ProductName
-- wniosek: select zwraca 72 pozycje sprzedawane od czerwca do sierpnia 

--Zad. 15
--Wy�wietl informacje o pracownikach, kt�rzy zostali zatrudnieni po zatrudnieniu pracownika Steven Buchanan.
select FirstName, LastName, HireDate from Employees
where (select HireDate from Employees where LastName = 'Buchanan') < HireDate
 -- wniosek1: jest trzech pracownik�w zatrudnianych p�niej ni� Buchanan.
 -- wniosek2: Nie ma podobnego przyk�adu z zagnie�d�aniem si� w tej samej tabeli, du�o czasu poch�ania rozwi�zanie 


--Zad. 16
--Podaj klient�w, kt�rzy z�o�yli kolejne zam�wienia po otrzymaniu dostawy z op�nieniem. 
-- dwa rozwi�zania - nr1:
SELECT DISTINCT o1.CustomerID
FROM Orders o1
JOIN Orders o2 
    ON o1.CustomerID = o2.CustomerID
    AND o1.OrderDate > o2.ShippedDate

---====== nr2:
SELECT DISTINCT ord1.CustomerID
FROM Orders ord1
WHERE EXISTS (SELECT * FROM Orders ord2
				WHERE ord2.CustomerID = ord1.CustomerID
				AND ord2.OrderDate > ord1.OrderDate AND ord2.ShippedDate > ord2.RequiredDate)
AND ord1.ShippedDate > ord1.RequiredDate
---====== wniosek: tworzy dwie te same tabele, ale inaczej je uk�ada tj: 1 tabel� uk�ada wg. sp�nie� dostawy dla danego klienta,
---====== drug� uk�ada r�wnie� wg. sp�nie� dostawy dla danego klienta ale dodatkowo por�wnuje daty zam�wie� pomi�dzy tabelami dla danego klienta,
---====== je�eli znajdzie dat� zam�wienia 


--Zad.17
--Ile i jakiego rodzaju zam�wie� z�o�yli poszczeg�lni klienci?
--Utw�rz odpowiedni widok.

select * from Orders ord 
join Customers cus on cus.CustomerID = ord.CustomerID 
join [Order Details] ode on ode.OrderID = ord.OrderID 
join Products pro on pro.ProductID = ode.ProductID 

--Rodzaje zam�wie�: ma�e - warto��<500,
--�rednie - warto��<1000,
--reszta to du�e.


create
--alter 
view widok_zamowien  -- ta wersja te� dzia�a, ale stwarza�a du�e problemy -- 
as
select cus.CompanyName, pro.ProductName ,  
case
when sum(ode.UnitPrice*ode.Quantity) <= 500 then 'ma�a warto�� zam�wienia'
when sum(ode.UnitPrice*ode.Quantity) <= 1000 then '�rednia warto�� zam�wienia'
else 'du�a warto�� zam�wienia'
end as Typy_zam,  --<-- ta nazwa nie chcia�a dzia��, ale w ko�cu zadzia�o, nie wiem czemu ??
count(*) as liczba_zam�wie�
from Orders ord 
join Customers cus on cus.CustomerID = ord.CustomerID 
join [Order Details] ode on ode.OrderID = ord.OrderID 
join Products pro on pro.ProductID = ode.ProductID 
group by cus.CompanyName , pro.ProductName 

--Wy�wietl nazw� klienta, rodzaj zam�wienia, liczb� zam�wie�.

select * from widok_zamowien

--Na koniec nale�y usun�� widok odpowiednim poleceniem.

drop view widok_zamowien


-- wersja druga 
create
--alter
view Zamowienia_klientow as -- ta wersja te� dziala dok�adnie tak samo --
select
    c.CompanyName, pro.ProductName,
    case
        when SUM(od.UnitPrice * od.Quantity) <= 500 then 'ma�a warto�� zam�wienia'
        when SUM(od.UnitPrice * od.Quantity) > 500 AND SUM(od.UnitPrice * od.Quantity) <= 1000 then '�rednia warto�� zam�wienia'
        else 'du�a warto�� zam�wienia'
    end as typy_zamowien , count(ord.OrderID) as liczba_zamowien
from 
    Customers c
join Orders ord on c.CustomerID = ord.CustomerID
join [Order Details] od on ord.OrderID = od.OrderID
join Products pro on od.ProductID = pro.ProductID
GROUP BY c.CompanyName, pro.ProductName

select * from Zamowienia_klientow
select * from widok_zamowien

--- obie wersje dzi��aj� dok�adnie tak samo, no chyba, �e czego� nie widz� i/lub nie wiem

drop view Zamowienia_klientow