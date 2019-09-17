-- add customer(s)
exec ADD_CUSTOMER @PCUSTID = 3, @PCUSTNAME = 'person1'
exec ADD_CUSTOMER @PCUSTID = 2, @PCUSTNAME = 'person2'

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

-----------------------------------------------------------------------------------

-- add product(s)
Exec ADD_PRODUCT @pprodid = 2000, @pproductname = 'banana', @pprice = 2;

-- delete product(s)
Begin
    Select dbo.DELETE_ALL_PRODUCTS() as 'Number of rows deleted:';
    exec DeletePROD;
End;

-- get product string 
exec GET_PROD_STRING @pprodid = 2000;

--update prod sales
exec UPD_PROD_SALESYTD @pprodid = 2000, @pamt = 500;

