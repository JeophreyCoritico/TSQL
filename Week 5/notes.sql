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