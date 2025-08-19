--Zad. 1
--Nale¿y wybraæ produkty sprzedawane w pude³kach (ang. box), gdzie zapas magazynowy jest w zakresie od 20 do 35, 
--a identyfikator kategorii produktu to 2 lub 3, u³o¿one w kolejnoœci od najdro¿szych.
--Wyœwietl nazwy produktów oraz wszystkie szczegó³y zwi¹zane z podanymi warunkami.
-----
select * from Products --wyœwietla wszystko z Products 
where (QuantityPerUnit like '%box%') and (UnitsInStock between 20 and 35) and (CategoryID in ('2', '3'))
order by UnitPrice desc
-----
select ProductName, CategoryID, UnitsInStock, QuantityPerUnit from Products --wyœwietla tylko 3 kolumny z Products 
where (QuantityPerUnit like '%box%') and (UnitsInStock between 20 and 35) and (CategoryID in ('2', '3'))
order by UnitPrice desc
-----wniosek tylko 3 produkty spe³niaj¹ powy¿sze kryteria.

--Zad. 2
--Nale¿y wybraæ zamówienia, gdzie kraj dostawy to Francja lub Niemcy, nazwa miasta zaczyna siê na literê B, K lub P, 
--zamówienie zosta³o dostarczone, w kolejnoœci sk³adania zamówieñ.
--Wyœwietl numery zamówieñ oraz wszystkie szczegó³y zwi¹zane z podanymi warunkami.
-----
select orderid, shipcountry, shipcity, orderdate, shippeddate from Orders
where (ShipCountry in ('Germany', 'France')) and (shipcity like 'B%' or shipcity like 'K%' or shipcity like 'P%') 
and (ShippedDate is not null)
order by OrderDate asc
--- wniosek 34 zamówienia spe³niaj¹ powy¿sze kryteria.

-----
--Zad. 3
--Podaj klientów, którzy z³o¿yli zamówienia w pierwszych 5 dniach ka¿dego miesi¹ca.
-----
select CustomerID --, OrderDate 
from orders where (day(OrderDate) between 1 and 5) 
 group by CustomerID
order by CustomerID
-----wniosek jest 63 klientów, którzy z³o¿yli zamówienia w pierwszych 5 dniach ka¿dego miesi¹ca.
-- niestety po d³u¿szym czasie niepowodzeñ skorzysta³em z chatgpt. Proste zadanie, ale mnie d³ugo siê zmaga³em z u¿yciem DATEADD co okaza³o siê pora¿k¹.

--Zad. 4
--Jaki jest œredni czas (w dniach) realizacji zamówienia (od z³o¿enia do wys³ania) przez poszczególnych pracowników.
--Wyœwietl dwie kolumny: identyfikator pracownika, œredni czas dostawy.
--Œrednia powinna byæ przedstawiona jako u³amek (liczba z przecinkiem).
-----
select EmployeeID, avg(cast(ShippeDdate - OrderDate as float)) as 'œrednia_czas_dostawy' from orders 
where ShippedDate is not null group by EmployeeID order by œrednia_czas_dostawy asc
----- wniosek: 9 pracowników ma œrednie czasy realizacji zamówieñ od 7 do 10 dni, nr.5 jest najlepszym pracownikiem.

--Zad. 5
--Jaka jest liczba pracowników urodzonych w poszczególnych latach.
--Wyœwietl dwie kolumny: rok urodzenia, liczba pracowników.
--- (dodaje tylko po to by wyœwietliæ co jest w orders) 
-----
select year(BirthDate) as 'rok urodzenia', count(*) as 'liczba_pracownikow' 
from Employees 
group by year(BirthDate)
----- wniosek: jest 9 pracowników, z czego 2 jest z rocznika 1963.

--Zad. 6
--Poka¿ pracowników, którzy w III kwartale 1996 roku przyjêli
--wiêcej ni¿ 5 zamówieñ.
--Wyœwietl identyfikator pracownika, liczbê zamówieñ.
----
select Employeeid, count(OrderID) as 'Liczba_Zamowien' from Orders --bez count() nie zadzia³a
where (year(OrderDate) = 1996) and (month(OrderDate) between 07 and 09) --pytanie czy to jest dobrze? czy da siê to zapisaæ krócej/inaczej na z u¿yciem Dateadd()?
group by Employeeid
having count(OrderID) > 5 
order by Employeeid
---- wniosek: pracownicy 5 i 9 musz¹ mieæ mniej ni¿ 5 zamówieñ we wskazanym przedziale czasowym.

--Zad. 7
--Ile zamówieñ zrealizowali poszczególni przewoŸnicy i ile ³¹cznie za nie dostali w roku 1997.
--Wyœwietl trzy kolumny: identyfikator przewoŸnika (ShipVia), liczba zamówieñ, koszt przewozu (Freight)
----
select ShipVia as 'identyfikator przewoŸnika', count(OrderID) as 'liczba zamówieñ', sum(Freight) as 'koszt_przewozu' from Orders
where year(ShippedDate) = 1997
group by ShipVia
order by ShipVia
----wniosek: 3 przewoŸników zrealizowa³o zamówienia w kolejnoœci 1 - 130, 2 - 143, 3 - 125

--Zad. 8
--Podaj klientów (z nazwy), którzy w 1997 roku z³o¿yli przynajmniej 3 zamówienia na produkty w s³oikach.
--Nazwy kolumn w kolejnoœci NAZWA_KLIENTA, LICZBA_ZAM
--- wersja rozwi¹zania z uzyciem join ----------
select o.CustomerID as 'NAZWA_KLIENTA', count(o.OrderID) as 'LICZBA_ZAM' from Orders o 
JOIN [Order Details] od on od.OrderID = o.OrderID 
JOIN Products p on od.ProductId = p.ProductId 
where year(o.OrderDate) = 1997 and p.QuantityPerUnit like '%jar%'
group by o.CustomerID
having count(o.OrderID) >= 3
	--- wniosek: 6 klientów w roku 1997 zamówi³o przynajmniej 3 s³oiki na zamówienie.
	-----------------------------
-----wersja rozwi¹zania bez join-------
select O.CustomerID as 'NAZWA_KLIENTA', Count(O.OrderID) as 'LICZBA_ZAM'
from Orders O where year(O.OrderDate) = 1997 and
O.OrderID in
	(select OD.OrderID from [Order Details] OD where OD.ProductId in
		(select P.ProductId from Products P where P.QuantityPerUnit like '%jar%'))
group by o.CustomerID
having count(o.OrderID) >= 3
--- wniosek: 6 klientów w roku 1997 zamówi³o przynajmniej 3 s³oiki na zamówienie
--- jest drobna ró¿nica w wynikach, wersja bez join obcina o jedno zamówienie, ale nie wiadomo dlaczego tak siê dzieje.

--Zad. 9
--ZnajdŸ wszystkich klientów pochodz¹cych z Niemiec, których ³¹czna wartoœæ zakupionego towaru jest wiêksza ni¿ 5000.
--Posortuj listê alfabetycznie wed³ug klientów.
--Wyœwietl nazwy kolumn w kolejnoœci: NAZWA_KLIENTA, WARTOŒÆ_ZAM
----- 
select cus.CustomerID as 'NAZWA_KLIENTA', sum(od.UnitPrice * od.Quantity) as 'WARTOŒÆ_ZAM' , cus.Country
from [Order Details] od join Orders ord on od.OrderID = ord.OrderID join Customers cus on ord.CustomerID = cus.CustomerID
where cus.Country = 'Germany'
group by cus.CustomerID, cus.Country
having sum(od.UnitPrice * od.Quantity) > 5000 
order by 'WARTOŒÆ_ZAM' desc
---- wniosek: tylko 7 klientów z Niemiec ma zamówienia > 5000.

--Zad. 10
--Podaæ pracowników oraz liczbê zamówieñ zrealizowanych w terminie, w latach 1997-1998
--Dane wyœwietl w kolejnoœci od najwiêkszej liczby zamówieñ.
--Nazwy kolumn w kolejnoœci IMIE, NAZWISKO, LICZBA_ZAM
-----------
select emp.FirstName, emp.LastName, count(ord.OrderID) as 'LICZBA_ZAM', year(ord.ShippedDate) as 'Rok' from Orders ord 
join Employees emp on ord.EmployeeID=emp.EmployeeID
where year(ord.ShippedDate) between 1997 and 1998
group by emp.FirstName, emp.LastName,  year(ord.ShippedDate)
order by count(ord.OrderID) desc
------ wniosek: 18 pracowników ma zrealizowane zamówienia w 1997-1998.

--Zad. 11   
-- ZnajdŸ klienta, który nigdy niczego nie kupi³, sprawdzaj¹c identyfikator klienta w tabeli zamówieñ. 
--- sprawdzenie:
select CustomerID from Customers
select CustomerID from Orders group by CustomerID
-- na podstawie ró¿nicy wyników w powy¿szych 2 selectach stwierdzono, ¿e s¹ klienci, którzy nie figuruj¹ w tabeli Orders, wiêc niczego nie zamówili,
-- i trzeba znaleŸæ, którzy to s¹. Powinno byæ 2 klientów, poniewa¿ selecty zwracaj¹ Customers=91 i Orders=89
select  cus.CustomerID as 'Customers.CustomerID', cus.CompanyName as 'Customers.CompanyName', ord.CustomerID as 'Orders.CustomerID'
from Orders ord right join Customers cus on ord.CustomerID = cus.CustomerID 
where ord.OrderID IS NULL
-- wniosek: zastosowano right join, poniewa¿ wa¿na jest ró¿nica miêdzy tabelami, która wype³ania siê 'NULL-ami
-- w tabeli Orders jest 2 klientów o nazwie Fissa i Paris bez realizowanych zamówieñ.

---- rozwi¹zanie numer 2 (ale to jest '¿ywcem' to samo co w przyk³adach, wiêc jest trochê dziwnie to podawaæ jako rozwi¹zanie - ??, 
-- ale dobrze znaæ takie rozwi¹zanie).
SELECT customerid, companyName FROM  customers
WHERE not EXISTS(SELECT orderid FROM  orders WHERE orders.customerid = customers.customerid)
----

--Zad. 12
--Wyœwietl informacje o produktach, gdzie rabat dla kategorii:
--Condiments wynosi 5%,
--Seafood wynosi 8%,
--Produce wynosi 15%,
--a dla pozosta³ych kategorii wynosi 4%
select * from Products

select cat.CategoryID, pro.ProductName, cat.CategoryName, case
when cat.CategoryID = 2 then pro.UnitPrice * 0.05
when cat.CategoryID = 8 then pro.UnitPrice * 0.08
when cat.CategoryID = 7 then pro.UnitPrice * 0.15
else pro.UnitPrice * 0.04
end AS 'Wysokoœæ_Rabatu'
from Categories cat
join Products pro on cat.CategoryID = pro.CategoryID
join [Order Details] od on pro.ProductID = od.ProductID
GROUP BY  cat.CategoryID, pro.ProductName, cat.CategoryName, pro.UnitPrice
ORDER BY cat.CategoryName
-- to zrobi³em w 100% samodzielnie!!

--Wyœwietl kolumny w kolejnoœci:
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

--Wyjaœnienie:
--*Cena przed rabatem to wartoœæ UnitPrice,
--*Cena po rabacie to wartoœæ UnitPrice obni¿ona o wartoœæ 4, 5, 8 lub 15%   dla odpowiedniej kategorii 
--*- trzeba napisaæ odpowiednie dzia³anie, aby cena po rabacie zosta³a wyliczona,
--*Rabat w procentach to odpowiednio 4, 5, 8 lub 15%.

--Zad. 13
--Wyœwietl (z nazwy) produkty niewycofane, gdy ich maksymalne ceny,
--po których zosta³y sprzedane s¹ równe przynajmniej 40$
--oraz produkty wycofane, gdy ich maksymalne ceny, po których zosta³y sprzedane s¹ wiêksze ni¿ 25$.
--Posortuj wed³ug informacji o wycofaniu i cen malej¹co.

select pro.ProductName as 'Nazwa_Produktu', pro.Discontinued as 'Informacja_o_Wycofaniu', max(ode.UnitPrice) as 'Cena_Waksymalna'
from Products pro
JOIN [Order Details] ode on pro.ProductID = ode.ProductID
where (pro.Discontinued = 1 and ode.UnitPrice >= 25) or (pro.Discontinued = 0 and ode.UnitPrice >= 40)
group by pro.Discontinued, pro.ProductName
order by 'Informacja_o_Wycofaniu' desc, 'Cena_Waksymalna' desc
-- wniosek: w sumie 15 produktów, z czego 5 jest wycofanych i 10 jest dopuszczonych do obrotu.

--Wyœwietl trzy kolumny:
--1) nazwa produktu
--2) informacja o wycofaniu
--3) cena maksymalna

--Wyjaœnienie:
--*Discontinued z tabeli Products - informacja o wycofaniu - wartoœæ 0 lub 1
--*maksymalne ceny, po których zosta³y sprzedane trzeba wybraæ z tabeli Orders Details,
--gdy¿ tylko tam s¹ ró¿ne ceny dla danego produktu.
--W tabeli Products zawsze jest jedna cena dla danego produktu.

--Zad. 14
--Podaj nazwy produktów, które nie by³y sprzedawane latem (od czerwca do sierpnia).
--====
select pro.ProductName from Products pro join [Order Details] ode on ode.ProductID = pro.ProductID join Orders ord on ord.OrderID = ode.OrderID 
where month(ord.ShippedDate) between 06 and 08 --and (ord.ShippedDate is not null) --<-- bez "not null" pokazuje tyle samo 72 pozycji
group by pro.ProductName
-- wniosek: select zwraca 72 pozycje sprzedawane od czerwca do sierpnia 

--Zad. 15
--Wyœwietl informacje o pracownikach, którzy zostali zatrudnieni po zatrudnieniu pracownika Steven Buchanan.
select FirstName, LastName, HireDate from Employees
where (select HireDate from Employees where LastName = 'Buchanan') < HireDate
 -- wniosek1: jest trzech pracowników zatrudnianych póŸniej ni¿ Buchanan.
 -- wniosek2: Nie ma podobnego przyk³adu z zagnie¿d¿aniem siê w tej samej tabeli, du¿o czasu poch³ania rozwi¹zanie 


--Zad. 16
--Podaj klientów, którzy z³o¿yli kolejne zamówienia po otrzymaniu dostawy z opóŸnieniem. 
-- dwa rozwi¹zania - nr1:
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
---====== wniosek: tworzy dwie te same tabele, ale inaczej je uk³ada tj: 1 tabelê uk³ada wg. spóŸnieñ dostawy dla danego klienta,
---====== drug¹ uk³ada równie¿ wg. spóŸnieñ dostawy dla danego klienta ale dodatkowo porównuje daty zamówieñ pomiêdzy tabelami dla danego klienta,
---====== je¿eli znajdzie datê zamówienia 


--Zad.17
--Ile i jakiego rodzaju zamówieñ z³o¿yli poszczególni klienci?
--Utwórz odpowiedni widok.

select * from Orders ord 
join Customers cus on cus.CustomerID = ord.CustomerID 
join [Order Details] ode on ode.OrderID = ord.OrderID 
join Products pro on pro.ProductID = ode.ProductID 

--Rodzaje zamówieñ: ma³e - wartoœæ<500,
--œrednie - wartoœæ<1000,
--reszta to du¿e.


create
--alter 
view widok_zamowien  -- ta wersja te¿ dzia³a, ale stwarza³a du¿e problemy -- 
as
select cus.CompanyName, pro.ProductName ,  
case
when sum(ode.UnitPrice*ode.Quantity) <= 500 then 'ma³a wartoœæ zamówienia'
when sum(ode.UnitPrice*ode.Quantity) <= 1000 then 'œrednia wartoœæ zamówienia'
else 'du¿a wartoœæ zamówienia'
end as Typy_zam,  --<-- ta nazwa nie chcia³a dzia³æ, ale w koñcu zadzia³o, nie wiem czemu ??
count(*) as liczba_zamówieñ
from Orders ord 
join Customers cus on cus.CustomerID = ord.CustomerID 
join [Order Details] ode on ode.OrderID = ord.OrderID 
join Products pro on pro.ProductID = ode.ProductID 
group by cus.CompanyName , pro.ProductName 

--Wyœwietl nazwê klienta, rodzaj zamówienia, liczbê zamówieñ.

select * from widok_zamowien

--Na koniec nale¿y usun¹æ widok odpowiednim poleceniem.

drop view widok_zamowien


-- wersja druga 
create
--alter
view Zamowienia_klientow as -- ta wersja te¿ dziala dok³adnie tak samo --
select
    c.CompanyName, pro.ProductName,
    case
        when SUM(od.UnitPrice * od.Quantity) <= 500 then 'ma³a wartoœæ zamówienia'
        when SUM(od.UnitPrice * od.Quantity) > 500 AND SUM(od.UnitPrice * od.Quantity) <= 1000 then 'œrednia wartoœæ zamówienia'
        else 'du¿a wartoœæ zamówienia'
    end as typy_zamowien , count(ord.OrderID) as liczba_zamowien
from 
    Customers c
join Orders ord on c.CustomerID = ord.CustomerID
join [Order Details] od on ord.OrderID = od.OrderID
join Products pro on od.ProductID = pro.ProductID
GROUP BY c.CompanyName, pro.ProductName

select * from Zamowienia_klientow
select * from widok_zamowien

--- obie wersje dzi¹³aj¹ dok³adnie tak samo, no chyba, ¿e czegoœ nie widzê i/lub nie wiem

drop view Zamowienia_klientow