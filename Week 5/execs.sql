-- CUSTOMER ---------------------------------------------------------------------------------
-- add customer(s)
exec ADD_CUSTOMER @PCUSTID = 3, @PCUSTNAME = 'person1'
exec ADD_CUSTOMER @PCUSTID = 2, @PCUSTNAME = 'person2'
exec ADD_CUSTOMER @PCUSTID = 22, @PCUSTNAME = 'person3'

-- delete customer(s)
Begin
    Select dbo.DELETE_ALL_CUSTOMERS() as 'Number of rows deleted:';
    exec DeleteCUST;
End;

-- get customer string
exec GET_CUSTOMER_STRING @pcustid = 3;

-- update cust sales
exec UPD_CUST_SALESYTD @pcustid = 3, @pamt = 500;
exec UPD_CUST_SALESYTD @pcustid = 2, @pamt = 0;

-- update cust status
exec UPD_CUSTOMER_STATUS @pcustid = 3, @pstatus = 'ok';
exec UPD_CUSTOMER_STATUS @pcustid = 2, @pstatus = 'suspend';

-- sum cust sales
begin
DECLARE @output NVARCHAR(MAX);
exec SUM_CUSTOMER_SALESYTD @sumcustsales = @output OUTPUT; 
SELECT @output as 'sum of customer sales_ytd';
end

-- get all customers
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

-- PRODUCT ---------------------------------------------------------------------------------

-- add product(s)
Exec ADD_PRODUCT @pprodid = 2000, @pproductname = 'banana', @pprice = 2;
Exec ADD_PRODUCT @pprodid = 2099, @pproductname = 'apple', @pprice = 4;
Exec ADD_PRODUCT @pprodid = 2209, @pproductname = 'grape', @pprice = 8;

-- delete product(s)
Begin
    Select dbo.DELETE_ALL_PRODUCTS() as 'Number of rows deleted:';
    exec DeletePROD;
End;

-- get product string 
exec GET_PROD_STRING @pprodid = 2000;

--update prod sales
exec UPD_PROD_SALESYTD @pprodid = 2000, @pamt = 500;
exec UPD_PROD_SALESYTD @pprodid = 2099, @pamt = 700;
exec UPD_PROD_SALESYTD @pprodid = 2209, @pamt = 250;

-- sum prod sales
begin
DECLARE @output2 NVARCHAR(MAX);
exec SUM_PRODUCT_SALESYTD @sumprodsales = @output2 OUTPUT; 
SELECT @output2 as 'sum of product sales_ytd';
end

-- get all products
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

-- SALES ---------------------------------------------------------------------------------

-- add simple sale(s)
exec ADD_SIMPLE_SALE  @pcustid = 3, @pprodid = 2000, @pqty = 20;
exec ADD_SIMPLE_SALE  @pcustid = 22, @pprodid = 2000, @pqty = 30;

-- add complex sale(s)
exec ADD_COMPLEX_SALE @pcustid = 3, @pprodid = 2000, @pqty = 20, @pdate = '20191007';
exec ADD_COMPLEX_SALE @pcustid = 22, @pprodid = 2000, @pqty = 30, @pdate = '20000922';
exec ADD_COMPLEX_SALE @pcustid = 22, @pprodid = 2209, @pqty = 10, @pdate = '19990921';

-- get all sales
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

-- LOCATION ---------------------------------------------------------------------------------

-- add location(s)
exec ADD_LOCATION @PLOCCODE = 71, @PMINQTY = 0, @PMAXQTY = 30;
exec ADD_LOCATION @PLOCCODE = 99, @PMINQTY = 66, @PMAXQTY = 777;
exec ADD_LOCATION @PLOCCODE = 24, @PMINQTY = 6, @PMAXQTY = 44;