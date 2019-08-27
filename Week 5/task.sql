IF OBJECT_ID('Sale') IS NOT NULL
DROP TABLE SALE;

IF OBJECT_ID('Product') IS NOT NULL
DROP TABLE PRODUCT;

IF OBJECT_ID('Customer') IS NOT NULL
DROP TABLE CUSTOMER;

IF OBJECT_ID('Location') IS NOT NULL
DROP TABLE LOCATION;

GO

CREATE TABLE CUSTOMER (
CUSTID	INT
, CUSTNAME	NVARCHAR(100)
, SALES_YTD	INT
, STATUS	NVARCHAR(7)
, PRIMARY KEY	(CUSTID) 
);


CREATE TABLE PRODUCT (
PRODID	INT
, PRODNAME	NVARCHAR(100)
, SELLING_PRICE	MONEY
, SALES_YTD	MONEY
, PRIMARY KEY	(PRODID)
);

CREATE TABLE SALE (
SALEID	INT
, CUSTID	INT
, PRODID	INT
, QTY	INT
, PRICE	MONEY
, SALEDATE	DATE
, PRIMARY KEY 	(SALEID)
, FOREIGN KEY 	(CUSTID) REFERENCES CUSTOMER
, FOREIGN KEY 	(PRODID) REFERENCES PRODUCT
);

CREATE TABLE LOCATION (
  LOCID	NVARCHAR(5)
, MINQTY	INTEGER
, MAXQTY	INTEGER
, PRIMARY KEY 	(LOCID)
, CONSTRAINT CHECK_LOCID_LENGTH CHECK (LEN(LOCID) = 5)
, CONSTRAINT CHECK_MINQTY_RANGE CHECK (MINQTY BETWEEN 0 AND 999)
, CONSTRAINT CHECK_MAXQTY_RANGE CHECK (MAXQTY BETWEEN 0 AND 999)
, CONSTRAINT CHECK_MAXQTY_GREATER_MIXQTY CHECK (MAXQTY >= MINQTY)
);

IF OBJECT_ID('SALE_SEQ') IS NOT NULL
DROP SEQUENCE SALE_SEQ;
CREATE SEQUENCE SALE_SEQ;

GO



-- ----------------------------------------------------------------------

If OBJECT_ID('ADD_CUSTOMER') is not NULL
Drop procedure ADD_CUSTOMER;
Go

Create PROCEDURE ADD_CUSTOMER @PCUSTID INT, @PCUSTNAME NVARCHAR(100) as 
begin 
    BEGIN TRY

        if @PCUSTID < 1 Or @PCUSTID > 499
        throw 50020, 'Customer ID is out of range', 1

        Insert into CUSTOMER (CUSTID, CUSTNAME, SALES_YTD, [STATUS])
        values (@PCUSTID, @PCUSTNAME, 0, 'OK');

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

Select * from customer;

-- ----------------------------------------------------------------------

If OBJECT_ID('DELETE_ALL_CUSTOMERS') is not NULL
Drop function DELETE_ALL_CUSTOMERS;
Go

If OBJECT_ID('DeleteCUST') is not NULL
Drop procedure DeleteCUST;
Go

create PROCEDURE DeleteCUST as
Begin
Delete from CUSTOMER
end
go

Create Function DELETE_ALL_CUSTOMERS() RETURNS NVARCHAR(30) as
BEGIN
Declare @NumRows INT
Select @NumRows = count(*) from (
    select CUSTID from CUSTOMER
) a
return concat('Number of rows deleted: ', @NumRows)
END;

Begin
Select dbo.DELETE_ALL_CUSTOMERS(); 
exec DeleteCUST;
End;
