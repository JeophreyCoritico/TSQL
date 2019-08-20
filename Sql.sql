-- Create PROCEDURE MULTIPLY @Number1 INT, @Number2 INT as 
-- BEGIN 
-- DECLARE @Product Int = @Number1 * @Number2;
--     select CONCAT('The product of ', @Number1, ' and ', @Number2, ' is ', @Product)
--     End;

-- Exec MULTIPLY @Number1 = 2, @Number2 = 4;

-----------------------------------------------------------------

-- Create FUNCTION adding (@Number1 INT, @Number2 INT ) returns NVARCHAR(30) as 
-- BEGIN    
-- Declare @Sum INT = @Number1 + @Number2;
-- return concat('The sum of ', @Number1, ' and ', @Number2, ' is ', @Sum)
-- End;

-- Begin 
-- Select dbo.adding(5,10);
-- End;

-----------------------------------------------------------------
Drop table Log;
Drop table Account;

Create table Account (
    AcctNo INT,
    FName NVARCHAR(30),
    LName NVARCHAR(30),
    CreditLimit INT,
    Balance INT,
    PRIMARY KEY (AcctNo)
    );

    Create table Log (
        OrigAcct INT,
        LogDateTime DATE,
        RecAcct INT,
        Amount INT,
        PRIMARY KEY (OrigAcct, LogDateTime),
        FOREIGN Key (OrigAcct) REFERENCES Account(AcctNo),
        FOREIGN Key (RecAcct) REFERENCES Account(AcctNo)
    );

INSERT INTO Account(AcctNo, FName, LName, CreditLimit, Balance)
VALUES
(1, 'Jeophrey', 'Coritico', 100, 100),
(2, 'Test', 'Test', 200, 200);

Drop PROCEDURE AccountPROC;

    Create PROCEDURE AccountPROC @FromAcctNo INT, @ToAcctNo INT, @Amount INT as 
    BEGIN 
    --Select CONCAT('From account: $', @FromAcctNo-@Amount, ' (-$', @Amount, '), To Account: $', @ToAcctNo+@Amount, ' (+$', @Amount, '), Amount: $', @Amount)
    
    Update Account SET
    Balance = Balance - @Amount
    where AcctNo = @FromAcctNo;

    Update Account SET
    Balance = Balance + @Amount
    where AcctNo = @ToAcctNo;

    insert into Log(OrigAcct, LogDateTime, RecAcct, Amount)
    VALUES (@FromAcctNo, GetDate(), @ToAcctNo, @Amount);

    -- Declare @Balance INT = @Amount-@FromAcctNo+@ToAcctNo
    -- INSERT into Account(Balance)
    -- VALUES
    -- (@Balance)

    END

    Exec AccountPROC @FromAcctNo = 2, @ToAcctNo = 1, @Amount = 100;
    
    Select * from Account;
    Select * from log;
