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
        Declare @NumRows INT
    Select @NumRows = count(*)
    from (
    select CUSTID
        from CUSTOMER
) a

if @pamt < -999.99 or @pamt > 999.99
throw 50080, 'Amount is out of range', 1

if @pcustid > @NumRows
THROW 50070, 'Customer ID is not found', 1

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

exec UPD_CUST_SALESYTD @pcustid = 1, @pamt = 500;
exec GET_CUSTOMER_STRING @pcustid = 1;

exec UPD_CUST_SALESYTD @pcustid = 1, @pamt = 100000;

select * from CUSTOMER