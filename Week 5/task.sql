IF OBJECT_ID('Sale') IS NOT NULL
DROP TABLE SALE;

IF OBJECT_ID('Product') IS NOT NULL
DROP TABLE PRODUCT;

IF OBJECT_ID('Customer') IS NOT NULL
DROP TABLE CUSTOMER;

IF OBJECT_ID('Location') IS NOT NULL
DROP TABLE LOCATION;

GO

CREATE TABLE CUSTOMER
(
    CUSTID INT
,
    CUSTNAME NVARCHAR(100)
,
    SALES_YTD INT
,
    STATUS NVARCHAR(7)
,
    PRIMARY KEY	(CUSTID)
);


CREATE TABLE PRODUCT
(
    PRODID INT
,
    PRODNAME NVARCHAR(100)
,
    SELLING_PRICE MONEY
,
    SALES_YTD MONEY
,
    PRIMARY KEY	(PRODID)
);

CREATE TABLE SALE
(
    SALEID INT
,
    CUSTID INT
,
    PRODID INT
,
    QTY INT
,
    PRICE MONEY
,
    SALEDATE DATE
,
    PRIMARY KEY 	(SALEID)
,
    FOREIGN KEY 	(CUSTID) REFERENCES CUSTOMER
,
    FOREIGN KEY 	(PRODID) REFERENCES PRODUCT
);

CREATE TABLE LOCATION
(
    LOCID NVARCHAR(5)
,
    MINQTY INTEGER
,
    MAXQTY INTEGER
,
    PRIMARY KEY 	(LOCID)
,
    CONSTRAINT CHECK_LOCID_LENGTH CHECK (LEN(LOCID) = 5)
,
    CONSTRAINT CHECK_MINQTY_RANGE CHECK (MINQTY BETWEEN 0 AND 999)
,
    CONSTRAINT CHECK_MAXQTY_RANGE CHECK (MAXQTY BETWEEN 0 AND 999)
,
    CONSTRAINT CHECK_MAXQTY_GREATER_MIXQTY CHECK (MAXQTY >= MINQTY)
);

IF OBJECT_ID('SALE_SEQ') IS NOT NULL
DROP SEQUENCE SALE_SEQ;
CREATE SEQUENCE SALE_SEQ;

GO



-- ------------------------------ ADD_CUSTOMER ------------------------------  

If OBJECT_ID('ADD_CUSTOMER') is not NULL
Drop procedure ADD_CUSTOMER;
Go

Create PROCEDURE ADD_CUSTOMER
    @PCUSTID INT,
    @PCUSTNAME NVARCHAR(100)
as
begin
    BEGIN TRY

        if @PCUSTID < 1 Or @PCUSTID > 499
        throw 50020, 'Customer ID is out of range', 1

        Insert into CUSTOMER
        (CUSTID, CUSTNAME, SALES_YTD, [STATUS])
    values
        (@PCUSTID, @PCUSTNAME, 0, 'OK');

    End TRY

    BEGIN CATCH
        IF ERROR_NUMBER() = 2627
            Throw 50010, 'Duplicate Customer ID', 1 
        ELSE IF ERROR_NUMBER() = 50020
            THROW
        ELSE    
            BEGIN
        Declare @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
        throw 50000, @ERRORMESSAGE, 1
    END;
    End CATCH;
END;

GO

Exec  ADD_CUSTOMER @PCUSTID = 1, @PCUSTNAME = 'testdude2';
Exec  ADD_CUSTOMER @PCUSTID = 2, @PCUSTNAME = 'testdude22';
Exec  ADD_CUSTOMER @PCUSTID = 3, @PCUSTNAME = 'testdude9';

-- Error Code: 50020
-- Error Message: Customer ID is out of range
Exec  ADD_CUSTOMER @PCUSTID = 500, @PCUSTNAME = 'testdude3';

-- Error Code: 50010
-- Error Message: Duplicate Customer ID
Exec  ADD_CUSTOMER @PCUSTID = 1, @PCUSTNAME = 'testdude4';

-- Error Code: Error message
Exec  ADD_CUSTOMER @PCUSTID = 'test', @PCUSTNAME = 'testdude5';

Select *
from customer;

-- ------------------------------ DELETE_ALL_CUSTOMERS ------------------------------
Exec  ADD_CUSTOMER @PCUSTID = 1, @PCUSTNAME = 'testdude2';
Exec  ADD_CUSTOMER @PCUSTID = 2, @PCUSTNAME = 'testdude22';
Exec  ADD_CUSTOMER @PCUSTID = 3, @PCUSTNAME = 'testdude9';
go

If OBJECT_ID('DELETE_ALL_CUSTOMERS') is not NULL
Drop function DELETE_ALL_CUSTOMERS;
Go

If OBJECT_ID('DeleteCUST') is not NULL
Drop procedure DeleteCUST;
Go

create PROCEDURE DeleteCUST
as
Begin
    Delete from CUSTOMER
end
go

Create Function DELETE_ALL_CUSTOMERS() RETURNS INT as
BEGIN
    Declare @NumRows INT
    Select @NumRows = count(*)
    from (
    select CUSTID
        from CUSTOMER
) a
    return @NumRows
END;

Begin
    Select dbo.DELETE_ALL_CUSTOMERS() as 'Number of rows deleted:';
    exec DeleteCUST;
End;

-- ------------------------------ ADD_PRODUCT ------------------------------
IF OBJECT_ID('ADD_PRODUCT') is not null
drop PROCEDURE ADD_PRODUCT;
go

create PROCEDURE ADD_PRODUCT
    @pprodid INT,
    @pproductname NVARCHAR(100),
    @pprice money
as
begin
    Begin TRY
        --throw 51000, 'this is a test message', 1 --this is to test error code

        if @pprodid < 1000 or @pprodid > 2500
        THROW 50040, 'Product ID is out of range', 1
        if @pprice < 0 or @pprice > 999.99 
        THROW 50050, 'Price is out of range', 1

        Insert into PRODUCT
        (PRODID, PRODNAME, SELLING_PRICE, SALES_YTD)
    values
        (@pprodid, @pproductname, @pprice, 0)
    end TRY

    Begin catch 
        if ERROR_NUMBER() = 2627
            throw 50030, 'Duplicate product ID', 1
        if ERROR_NUMBER() = 50040
            THROW
        if ERROR_NUMBER() = 50050
            THROW
        Else 
            BEGIN
        Declare @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
        Throw 50000, @ERRORMESSAGE, 1
    End;
    End CATCH
END

-- should work
Exec ADD_PRODUCT @pprodid = 2209, @pproductname = 'banana', @pprice = 20;

-- error code 50040 - product id is out of range
Exec ADD_PRODUCT @pprodid = 999, @pproductname = 'apple', @pprice = 20;
Exec ADD_PRODUCT @pprodid = 3000, @pproductname = 'apple', @pprice = 20;

-- error code 50030 - duplicate product id
Exec ADD_PRODUCT @pprodid = 2209, @pproductname = 'pear', @pprice = 20;

-- error code 50050 - price is out of range
Exec ADD_PRODUCT @pprodid = 2210, @pproductname = 'peach', @pprice = 1000;
Exec ADD_PRODUCT @pprodid = 2211, @pproductname = 'peach', @pprice = -300;

-- error code 50000 - use value of error_message()
Exec ADD_PRODUCT @pprodid = 'test', @pproductname = 'mango', @pprice = 20;
Exec ADD_PRODUCT @pprodid = 2212, @pproductname = 'mango', @pprice = 'test';


select *
from PRODUCT;

-- ------------------------------ DELETE_ALL_PRODUCTS_FROM_DB ------------------------------

If OBJECT_ID('DELETE_ALL_PRODUCTS') is not NULL
Drop function DELETE_ALL_PRODUCTS;
Go

If OBJECT_ID('DeletePROD') is not NULL
Drop procedure DeletePROD;
Go

create PROCEDURE DeletePROD
as
Begin
    begin try 
    Delete from PRODUCT
    end TRY
    
        begin catch 
    begin
        DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
        throw 50000, @ERRORMESSAGE, 1
    END
    end catch
end
go

Create Function DELETE_ALL_PRODUCTS() RETURNS INT as
BEGIN
    Declare @NumRows INT
    Select @NumRows = count(*)
    from (
    select PRODID
        from PRODUCT
) a
    return @NumRows
END;

Begin
    Select dbo.DELETE_ALL_PRODUCTS() as 'Number of rows deleted:';
    exec DeletePROD;
End;

select *
from PRODUCT;

-- ------------------------------ GET_CUSTOMER_STRING ------------------------------

If OBJECT_ID('GET_CUSTOMER_STRING') is not NULL
Drop procedure GET_CUSTOMER_STRING;
Go

create PROCEDURE GET_CUSTOMER_STRING
    @pcustid int
as
BEGIN
    begin try 

Declare @StringofCUST VARCHAR(MAX)

select @StringofCUST = CONCAT('CustID: ', CUSTID, '   ', 'Name: ', CUSTNAME, '   ', 'Status ', STATUS, '   ', 'SalesYTD: ', SALES_YTD, '   ')
    from CUSTOMER
    where CUSTID = @pcustid;

if @StringofCUST is NULL
throw 50060, 'Customer ID not found', 1

SELECT @StringofCUST as 'Customer:';
END TRY

begin catch 
    if ERROR_NUMBER() = 50060
    THROW
end catch
END;

Exec  ADD_CUSTOMER @PCUSTID = 1, @PCUSTNAME = 'testdude2';
Exec  ADD_CUSTOMER @PCUSTID = 2, @PCUSTNAME = 'testdude22';
Exec  ADD_CUSTOMER @PCUSTID = 3, @PCUSTNAME = 'testdude9';

select *
from CUSTOMER;
-- Should work
exec GET_CUSTOMER_STRING @pcustid = 2;
-- Should not work
exec GET_CUSTOMER_STRING @pcustid = 69;

-- ------------------------------ UPD_CUST_SALESYTD ------------------------------

If OBJECT_ID('UPD_CUST_SALESYTD') is not NULL
Drop procedure UPD_CUST_SALESYTD;
Go

create PROCEDURE UPD_CUST_SALESYTD
    @pcustid int,
    @pamt int
AS
Begin
    begin TRY

if not exists (
    select @pcustid
    from CUSTOMER
    where CUSTID = @pcustid
)   
throw 50070, 'Customer ID is not found', 1

if @pamt < -999.99 or @pamt > 999.99
throw 50080, 'Amount is out of range', 1

    update CUSTOMER SET
SALES_YTD = SALES_YTD + @pamt
where CUSTID = @pcustid;
end TRY

begin CATCH 
    If ERROR_NUMBER() = 50080
    THROW
    if ERROR_NUMBER() = 50070
    THROW
end CATCH
End

-- should work
exec UPD_CUST_SALESYTD @pcustid = 1, @pamt = 500;
-- error code 50080 - amount is out of range
exec UPD_CUST_SALESYTD @pcustid = 1, @pamt = 100000;
-- error code 50070 - custID does not exist
exec UPD_CUST_SALESYTD @pcustid = 30, @pamt = 500;

select *
from CUSTOMER

-- ------------------------------ GET_PROD_STRING ------------------------------

If OBJECT_ID('GET_PROD_STRING') is not NULL
Drop procedure GET_PROD_STRING;
Go

create PROCEDURE GET_PROD_STRING
    @pprodid int
as
BEGIN
    begin try 

Declare @StringofPROD VARCHAR(MAX)

select @StringofPROD = CONCAT('Prodid: ', PRODID, '   ', 'Name: ', PRODNAME, '   ', 'Price ', SELLING_PRICE, '   ', 'SalesYTD: ', SALES_YTD, '   ')
    from PRODUCT
    where PRODID = @pprodid;

if @StringofPROD is NULL
throw 50090, 'Product ID not found', 1

SELECT @StringofPROD as 'Customer:';
END TRY

begin catch 
    if ERROR_NUMBER() = 50090
    THROW
end catch
END;

Exec ADD_PRODUCT @pprodid = 2209, @pproductname = 'banana', @pprice = 20;
Exec ADD_PRODUCT @pprodid = 2210, @pproductname = 'apple', @pprice = 40;
Exec ADD_PRODUCT @pprodid = 2211, @pproductname = 'mango', @pprice = 70;

exec GET_PROD_STRING @pprodid = 2210;
exec GET_PROD_STRING @pprodid = 7;
select *
from PRODUCT

-- ------------------------------ UPD_PROD_SALESYTD ------------------------------

If OBJECT_ID('UPD_PROD_SALESYTD') is not NULL
Drop procedure UPD_PROD_SALESYTD;
Go

create PROCEDURE UPD_PROD_SALESYTD
    @pprodid int,
    @pamt int
AS
Begin
    begin TRY

if not exists (
    select @pprodid
    from PRODUCT
    where PRODID = @pprodid
)   
throw 50100, 'Product ID is not found', 1

if @pamt < -999.99 or @pamt > 999.99
throw 50110, 'Amount is out of range', 1

    update PRODUCT SET
SALES_YTD = SALES_YTD + @pamt
where PRODID = @pprodid;
end TRY

begin CATCH 
    If ERROR_NUMBER() = 50100
    THROW
    if ERROR_NUMBER() = 50110
    THROW
end CATCH
End

-- should work
exec UPD_PROD_SALESYTD @pprodid = 2209, @pamt = 500;
-- error code 50080 - amount is out of range
exec UPD_PROD_SALESYTD @pprodid = 2209, @pamt = 500000;
-- error code 50070 - custID does not exist
exec UPD_PROD_SALESYTD @pprodid = 2, @pamt = 500;

select *
from PRODUCT

-- ------------------------------ UPD_CUSTOMER_STATUS ------------------------------

If OBJECT_ID('UPD_CUSTOMER_STATUS') is not NULL
Drop procedure UPD_CUSTOMER_STATUS;
Go

create PROCEDURE UPD_CUSTOMER_STATUS
    @pcustid int,
    @pstatus NVARCHAR(7)
AS
begin
    BEGIN TRY

if not exists (
    select @pcustid
    from CUSTOMER
    where CUSTID = @pcustid
)   
throw 50120, 'Customer ID is not found', 1

if @pstatus = 'OK' or @pstatus = 'SUSPEND'
    update CUSTOMER SET
STATUS = UPPER(@pstatus)
where CUSTID = @pcustid;
ELSE
THROW 50130, 'Invalid status value', 1

end TRY

begin CATCH 
    If ERROR_NUMBER() = 50120
    THROW
    if ERROR_NUMBER() = 50130
    THROW
end CATCH
End

-- should work
exec UPD_CUSTOMER_STATUS @pcustid = 1, @pstatus = 'ok';
exec UPD_CUSTOMER_STATUS @pcustid = 2, @pstatus = 'suspend';
-- 50120 Cust ID not found
exec UPD_CUSTOMER_STATUS @pcustid = 40, @pstatus = 'suspend';
-- 50130 Invalid status value
exec UPD_CUSTOMER_STATUS @pcustid = 3, @pstatus = 'test';

select *
from CUSTOMER

-- ------------------------------ ADD_SIMPLE_SALE ------------------------------

If OBJECT_ID('ADD_SIMPLE_SALE') is not NULL
Drop procedure ADD_SIMPLE_SALE;
Go

create PROCEDURE ADD_SIMPLE_SALE
    @pcustid int,
    @pprodid int,
    @pqty INT
as
BEGIN
    begin TRY
DECLARE
@thiscustid int = @pcustid,
@thisprodid int = @pprodid;

DECLARE 
@prices int 
select @prices = SELLING_PRICE
    from PRODUCT
    where PRODID = @pprodid;  

DECLARE
@pqtypriceprod int = @pqty * @prices;

if not exists (
    select @pcustid
    from CUSTOMER
    where CUSTID = @thiscustid
)   
throw 50160, 'Customer ID is not found', 1


if not exists (
    select @thisprodid
    from PRODUCT
    where PRODID = @thisprodid
)   
throw 50170, 'Product ID is not found', 1

if exists (
    SELECT @thiscustid
    from CUSTOMER
    WHERE CUSTID = @thiscustid and STATUS = 'SUSPEND'
)
THROW 50150, 'Customer status is not OK', 1

if @pqty < 1 or @pqty > 999
THROW 50140, 'Sale quantity is out of range', 1

exec UPD_CUST_SALESYTD @pcustid = @thiscustid, @pamt = @pqtypriceprod;
exec UPD_PROD_SALESYTD @pprodid = @thisprodid, @pamt = @pqtypriceprod;

end TRY

begin CATCH 
    If ERROR_NUMBER() = 50140
    THROW
    if ERROR_NUMBER() = 50150
    THROW
    if ERROR_NUMBER() = 50160
    THROW
    if ERROR_NUMBER() = 50170
    THROW
end CATCH
End

-- should work
exec ADD_SIMPLE_SALE  @pcustid = 3, @pprodid = 2000, @pqty = 20;
exec ADD_SIMPLE_SALE  @pcustid = 22, @pprodid = 2000, @pqty = 30;
-- 50140 sale qty is out of range
exec ADD_SIMPLE_SALE  @pcustid = 3, @pprodid = 2000, @pqty = 999999;
-- 50150 customer is not ok
exec ADD_SIMPLE_SALE  @pcustid = 2, @pprodid = 2000, @pqty = 20;
-- 50160 cust id not found
exec ADD_SIMPLE_SALE  @pcustid = 5, @pprodid = 2000, @pqty = 20;
-- 50170 prod id not found
exec ADD_SIMPLE_SALE  @pcustid = 3, @pprodid = 5, @pqty = 20;

select *
from CUSTOMER
select *
from PRODUCT

-- ------------------------------ SUM_CUSTOMER_SALESYTD ------------------------------

If OBJECT_ID('SUM_CUSTOMER_SALESYTD') is not NULL
Drop procedure SUM_CUSTOMER_SALESYTD;
Go

create PROCEDURE SUM_CUSTOMER_SALESYTD
    @sumcustsales int OUTPUT
as
begin
    select @sumcustsales = sum(SALES_YTD)
    from(
    select SALES_YTD
        from CUSTOMER
)a
    return @sumcustsales
end

begin
    DECLARE @output NVARCHAR(MAX);
    exec SUM_CUSTOMER_SALESYTD @sumcustsales = @output OUTPUT;
    SELECT @output as 'sum of customer sales_ytd';
end

-- ------------------------------ SUM_PRODUCT_SALESYTD ------------------------------

If OBJECT_ID('SUM_PRODUCT_SALESYTD') is not NULL
Drop procedure SUM_PRODUCT_SALESYTD;
Go

create PROCEDURE SUM_PRODUCT_SALESYTD
    @sumprodsales int OUTPUT
as
begin
    select @sumprodsales = sum(SALES_YTD)
    from(
    select SALES_YTD
        from PRODUCT
)a
    return @sumprodsales
end

begin
    DECLARE @output NVARCHAR(MAX);
    exec SUM_PRODUCT_SALESYTD @sumprodsales = @output OUTPUT;
    SELECT @output as 'sum of product sales_ytd';
end

-- ------------------------------ GET_ALL_CUSTOMERS ------------------------------

If OBJECT_ID('GET_ALL_CUSTOMERS') is not NULL
Drop procedure GET_ALL_CUSTOMERS;
Go

create PROCEDURE GET_ALL_CUSTOMERS
    @POUTCUR CURSOR VARYING OUTPUT
as
begin
    begin try 
set @POUTCUR = CURSOR for SELECT *
    from CUSTOMER;
    open @POUTCUR;
end TRY
begin catch 
declare @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
throw 50000, @ERRORMESSAGE, 1
end CATCH
end

begin
    declare @CUR CURSOR;

    exec GET_ALL_CUSTOMERS @POUTCUR = @CUR OUTPUT;

    declare 
@custID Int,
@CUSTNAME nvarchar(100),
@SalesYTD money,
@Status NVARCHAR(7);

    fetch next from @CUR into @custid, @CUSTNAME, @salesytd, @status;

    while @@FETCH_STATUS = 0

    begin
        print(concat('ID: ', @custID, ', ', 'Name: ', @CUSTNAME, ', ', 'Sales YTD: ', @salesytd, ', ', 'Status: ', @status))
        FETCH next from @CUR into @custID, @CUSTNAME, @salesytd, @Status;
    END

    close @CUR
    deallocate @CUR
end

-- ------------------------------ GET_ALL_PRODUCTS ------------------------------

If OBJECT_ID('GET_ALL_PRODUCTS') is not NULL
Drop procedure GET_ALL_PRODUCTS;
Go

create PROCEDURE GET_ALL_PRODUCTS
    @POUTCUR CURSOR VARYING OUTPUT
as
begin
    begin try 
set @POUTCUR = CURSOR for SELECT *
    from PRODUCT;
    open @POUTCUR;
end TRY
begin catch 
declare @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
throw 50000, @ERRORMESSAGE, 1
end CATCH
end

begin
    declare @CUR CURSOR;

    exec GET_ALL_PRODUCTS @POUTCUR = @CUR OUTPUT;

    declare 
@prodID Int,
@PRODNAME nvarchar(100),
@SELLING_PRICE money,
@SALES_YTD money;

    fetch next from @CUR into @prodID, @PRODNAME, @SELLING_PRICE, @SALES_YTD;

    while @@FETCH_STATUS = 0

    begin
        print(concat('ID: ', @prodID, ', ', 'Name: ', @PRODNAME, ', ', 'Selling Price: ', @SELLING_PRICE, ', ', 'Sales_YTD: ', @SALES_YTD))
        FETCH next from @CUR into @prodID, @PRODNAME, @SELLING_PRICE, @SALES_YTD;
    END

    close @CUR
    deallocate @CUR
end

-- ------------------------------ ADD_LOCATION ------------------------------

If OBJECT_ID('ADD_LOCATION') is not NULL
Drop procedure ADD_LOCATION;
Go

Create PROCEDURE ADD_LOCATION
    @PLOCCODE NVARCHAR(5),
    @PMINQTY INT,
    @PMAXQTY INT
as
begin
    BEGIN TRY

    -- DECLARE @lengthcheck NVARCHAR(5) = '12345';

        if @PMINQTY < 0 Or @PMINQTY > 999
        throw 50200, 'Minimum Qty is out of range', 1
        
        if @PMAXQTY < 0 Or @PMAXQTY > 999
        throw 50210, 'Maximum Qty is out of range', 1

        if @PMINQTY > @PMAXQTY
        THROW 50220, 'Minimum Qty larger than Maximum Qty', 1

        if @PLOCCODE like '[A-Za-z]%' or @PLOCCODE > 99 
        THROW 50190, 'Location Code length invalid', 1

        Insert into [LOCATION]
        (LOCID, MINQTY, MAXQTY)
    values
        ('loc' + @PLOCCODE, @PMINQTY, @PMAXQTY);

    End TRY

    BEGIN CATCH
        IF ERROR_NUMBER() = 2627
            Throw 50180, 'Duplicate Location ID', 1 
        else if ERROR_NUMBER() = 50190
        THROW
        else if ERROR_NUMBER() = 50200
        THROW
        else if ERROR_NUMBER() = 50210
        THROW
        else if ERROR_NUMBER() = 50220
        THROW
            BEGIN
        Declare @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
        throw 50000, @ERRORMESSAGE, 1
    END;
    End CATCH;
END;
GO
-- should work
exec ADD_LOCATION @PLOCCODE = 71, @PMINQTY = 0, @PMAXQTY = 30;
exec ADD_LOCATION @PLOCCODE = 99, @PMINQTY = 66, @PMAXQTY = 777;
exec ADD_LOCATION @PLOCCODE = 24, @PMINQTY = 6, @PMAXQTY = 44;

-- ERROR 50190, location code lengthinvalid
exec ADD_LOCATION @PLOCCODE = 222, @PMINQTY = 9, @PMAXQTY = 200;
go
exec ADD_LOCATION @PLOCCODE = aa, @PMINQTY = 9, @PMAXQTY = 200;

-- ERROR 50200, Min Qty is out of range
exec ADD_LOCATION @PLOCCODE = 12, @PMINQTY = -27, @PMAXQTY = 20;
exec ADD_LOCATION @PLOCCODE = 12, @PMINQTY = 2003, @PMAXQTY = 20;

-- ERROR 50210, Max Qty is out of range
exec ADD_LOCATION @PLOCCODE = 26, @PMINQTY = 22, @PMAXQTY = -42;
exec ADD_LOCATION @PLOCCODE = 26, @PMINQTY = 22, @PMAXQTY = 3005;

--ERROR 50220, Min Qty is larger than Max Qty
exec ADD_LOCATION @PLOCCODE = 31, @PMINQTY = 67, @PMAXQTY = 35;

select *
from [LOCATION];

-- ------------------------------ ADD_COMPLEX_SALE ------------------------------

If OBJECT_ID('ADD_COMPLEX_SALE') is not NULL
Drop procedure ADD_COMPLEX_SALE;
Go

create PROCEDURE ADD_COMPLEX_SALE
    @pcustid int,
    @pprodid int,
    @pqty INT,
    @pdate NVARCHAR(Max)
as
BEGIN
    begin TRY
DECLARE 
@prices int 
select @prices = SELLING_PRICE
    from PRODUCT
    where PRODID = @pprodid;  

DECLARE
@pqtypriceprod int = @pqty * @prices;

    DECLARE
@thiscustid int = @pcustid,
@thisprodid int = @pprodid;


    DECLARE @Id INT
    set @Id = 0
    Select @Id = MAX(SALEID)
    from (
    select SALEID
        from SALE
) a
    set @Id = @Id + 1

if not exists (
    select @thiscustid
    from CUSTOMER
    where CUSTID = @thiscustid
)   
throw 50260, 'Customer ID is not found', 1

if not exists (
    select @thisprodid
    from PRODUCT
    where PRODID = @thisprodid
)   
throw 50270, 'Product ID is not found', 1

if exists (
    SELECT @thiscustid
    from CUSTOMER
    WHERE CUSTID = @thiscustid and STATUS = 'SUSPEND'
)
THROW 50240, 'Customer status is not OK', 1

if @pqty < 1 or @pqty > 999
THROW 50230, 'Sale quantity is out of range', 1

if @pdate like '[A-Za-z]%'
throw 50250, 'Date not valid', 1

select CONVERT([datetime], @pdate, 111);

exec UPD_CUST_SALESYTD @pcustid = @thiscustid, @pamt = @pqtypriceprod;
exec UPD_PROD_SALESYTD @pprodid = @thisprodid, @pamt = @pqtypriceprod;

        Insert into [SALE]
        (SALEID, CUSTID, PRODID, QTY, PRICE, SALEDATE)
    values
        (@Id, @pcustid, @pprodid, @pqty, @prices, @pdate);

end TRY

begin CATCH 
if ERROR_NUMBER() = 50230
THROW
else if ERROR_NUMBER() = 50240
THROW
else if ERROR_NUMBER() = 50250
THROW
else if ERROR_NUMBER() = 50260
THROW
else if ERROR_NUMBER() = 50270
THROW
    BEGIN
        Declare @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
        throw 50000, @ERRORMESSAGE, 1
    END;
end CATCH
End
GO

-- should work
exec ADD_COMPLEX_SALE @pcustid = 3, @pprodid = 2000, @pqty = 20, @pdate = '20191007';
exec ADD_COMPLEX_SALE @pcustid = 22, @pprodid = 2000, @pqty = 30, @pdate = '20000922';
exec ADD_COMPLEX_SALE @pcustid = 22, @pprodid = 2209, @pqty = 10, @pdate = '19990921';


-- ERROR 50230, sale quantity out of range
exec ADD_COMPLEX_SALE @pcustid = 3, @pprodid = 2209, @pqty = 2345, @pdate = '19990921';

-- ERROR 50240, customer status is not OK
exec ADD_COMPLEX_SALE @pcustid = 2, @pprodid = 2209, @pqty = 10, @pdate = '19990921';

-- ERROR 50250, date not valid
exec ADD_COMPLEX_SALE @pcustid = 3, @pprodid = 2209, @pqty = 10, @pdate = 'test';

-- ERROR 50260, customer not found
exec ADD_COMPLEX_SALE @pcustid = 11, @pprodid = 2209, @pqty = 10, @pdate = '19990921';

-- ERROR 50270, product not found
exec ADD_COMPLEX_SALE @pcustid = 3, @pprodid = 1234, @pqty = 10, @pdate = '19990921';

-- ------------------------------ GET_ALL_SALES ------------------------------

If OBJECT_ID('GET_ALL_SALES') is not NULL
Drop procedure GET_ALL_SALES;
Go

create PROCEDURE GET_ALL_SALES
    @POUTCUR CURSOR VARYING OUTPUT
as
begin
    begin try 
set @POUTCUR = CURSOR for SELECT *
    from SALE;
    open @POUTCUR;
end TRY
begin catch 
declare @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
throw 50000, @ERRORMESSAGE, 1
end CATCH
end
GO

begin
    declare @CUR CURSOR;

    exec GET_ALL_SALES @POUTCUR = @CUR OUTPUT;

    declare 
@saleID Int,
@custID Int,
@prodID INT,
@qty INT,
@price money,
@saleDate date;

    fetch next from @CUR into @saleID, @custid, @prodID, @qty, @price, @saleDate;

    while @@FETCH_STATUS = 0

    begin
        print(concat('Sale ID: ', @saleID, ', ', 'Customer ID: ', @custid, ', ', 'Product ID: ', @prodID, ', ', 'Quantity: ', @qty, ', ', 'Price: ', @price, ', ', 'Sale Date: ', @saleDate))
        FETCH next from @CUR into @saleID, @custid, @prodID, @qty, @price, @saleDate;
    END

    close @CUR
    deallocate @CUR
end

-- ------------------------------ COUNT_PRODUCT_SALES ------------------------------

If OBJECT_ID('COUNT_PRODUCT_SALES') is not NULL
Drop procedure COUNT_PRODUCT_SALES;
Go

create PROCEDURE COUNT_PRODUCT_SALES @pdays INT
as
begin
begin try
DECLARE @currentDate int 
set @currentDate = cast(convert(char(8), getdate(), 112) as int)

declare @dateWithin int
set @dateWithin = @currentDate - @pdays

Declare @total INT
    Select @total = sum(QtyPriProd)
    from (
    select QTY * PRICE as QtyPriProd
        from SALE
        where cast(convert(char(8), SALEDATE, 112) as int) <= @dateWithin
) a 

declare @concDateWithin date 
set @concDateWithin = CONVERT(datetime, convert(varchar(10), @dateWithin))

declare @concCurrentDate date 
set  @concCurrentDate = CONVERT(datetime, convert(varchar(10), @currentDate))

print(concat('Number of day(s) of current date: ', @pdays, ' Days, ', 'Date chosen: ', @concDateWithin, ', ', 'Current Date: ', @concCurrentDate, ', ', ' Total: ', @total))

select @total as 'Total:'

end TRY
begin CATCH
BEGIN
        Declare @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
        throw 50000, @ERRORMESSAGE, 1
    END;
end catch 
END
GO

exec COUNT_PRODUCT_SALES @pdays = 3;

-- ------------------------------ DELETE_SALE ------------------------------

If OBJECT_ID('DELETE_SALE') is not NULL
Drop procedure DELETE_SALE;
Go

create PROCEDURE DELETE_SALE 
as
begin
begin TRY

declare @minSale INT
select @minSale = MIN(SaleID) 
    from (
    select SALEID
        from SALE
) a

declare @minSaleCustID INT
select @minSaleCustID 
    from (
    select CUSTID
        from SALE
        where SALEID = @minSale
) a

declare @minSaleProdID INT
select @minSaleProdID 
    from (
    select PRODID
        from SALE
        where SALEID = @minSale
) a

declare @minSaleQtyPrice INT
select @minSaleProdID
    from (
    select QTY * PRICE as QtyPrice
        from SALE
        where SALEID = @minSale
) a

if not exists (
    select @minSale
    from SALE
    where SALEID = @minSale
)   
throw 50280, 'No sale rows found', 1

set @minSaleQtyPrice = @minSaleQtyPrice * -1

exec UPD_CUST_SALESYTD @pcustid = @minSaleCustID, @pamt = @minSaleQtyPrice;
exec UPD_PROD_SALESYTD @pprodid = @minSaleCustID, @pamt = @minSaleQtyPrice;

print(concat(@minSale, ' ', @minSaleCustID, ' ', @minSaleProdID))

select @minSale as 'SALEID:'

delete from SALE
    where SALEID = @minSale

end TRY
begin  CATCH
    if ERROR_NUMBER() = 50280
        THROW
            BEGIN
        Declare @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
        throw 50000, @ERRORMESSAGE, 1
    END;
end CATCH 
end
go

exec DELETE_SALE

-- ------------------------------ DELETE_ALL_SALES ------------------------------

If OBJECT_ID('DELETE_ALL_SALES') is not NULL
Drop function DELETE_ALL_SALES;
Go

If OBJECT_ID('DeleteSALES') is not NULL
Drop procedure DeleteSALES;
Go

create PROCEDURE DeleteSALES
as
Begin
    Delete from SALE

update CUSTOMER SET
SALES_YTD = 0;

update PRODUCT SET
SALES_YTD = 0;

end
go

Create Function DELETE_ALL_SALES() RETURNS INT as
BEGIN
    Declare @NumRows INT
    Select @NumRows = count(*)
    from (
    select SALEID
        from SALE
) a
    return @NumRows
END;
GO

Begin
    Select dbo.DELETE_ALL_SALES() as 'Number of rows deleted:';
    exec DeleteSALES;
End;

-- ------------------------------ DELETE_CUSTOMER ------------------------------

If OBJECT_ID('DELETE_CUSTOMER') is not NULL
Drop procedure DELETE_CUSTOMER;
Go

create PROCEDURE DELETE_CUSTOMER @pCustID int  
as
begin
begin TRY

if not exists (
    select @pCustID
    from CUSTOMER
    where CUSTID = @pcustid
)   
throw 50290, 'Customer ID is not found', 1

delete from CUSTOMER
    where CUSTID = @pCustID

end TRY
begin CATCH
if ERROR_NUMBER() = 50290
THROW
BEGIN
        Declare @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
        throw 50000, @ERRORMESSAGE, 1
    END;
end CATCH 
end
go

-- should work
exec DELETE_CUSTOMER @pCustID = 3

-- ERROR 50290, Customer ID is not found
exec DELETE_CUSTOMER @pCustID = 300
