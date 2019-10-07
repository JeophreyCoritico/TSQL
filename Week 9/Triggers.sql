-- Create table StudentTRIG 
-- (
--     StudentID int,
--     Surname NVARCHAR(max),
--     Givename NVARCHAR(max),
--     mobile INT,
    
--     primary key (StudentID)
-- )
-- GO

-- create table LogTRIG
-- (
--     LogID int,
--     StudentID int,
--     DateTimeChanged date,
--     DBUser NVARCHAR(max),
--     OldSurname NVARCHAR(max),
--     NewSurname NVARCHAR(max),
--     OldGivename NVARCHAR(max),
--     NewGivename NVARCHAR(max),
--     OldMobile INT,
--     NewMobile INT,

--     primary key (LogID),
--     FOREIGN key (StudentID) references StudentTRIG
-- )

drop sequence LogIdSeq
GO

create sequence LogIdSeq 
start with 1
INCREMENT by 1
cycle;

drop TRIGGER TR_INS_Students
go
delete from StudentTRIG
GO
delete from LogTRIG
go

Create TRIGGER TR_INS_Students on StudentTRIG 
for insert
not for replication
as
BEGIN
insert into LogTRIG (LogID, StudentID, DateTimeChanged, DBUser, OldSurname,
NewSurname, OldGivename, NewGivename, OldMobile, NewMobile)
select Next value for LogIdSeq, i.StudentID, GETDATE(), CURRENT_USER, null, 
i.Surname, null, i.Givename, null, i.mobile 
from inserted i
end 
GO

drop TRIGGER TR_INS_Students
go

create TRIGGER TR_UPD_Students on StudentTRIG
for update 
not for replication
AS
BEGIN
insert into LogTRIG (LogID, StudentID, DateTimeChanged, DBUser, OldSurname,
NewSurname, OldGivename, NewGivename, OldMobile, NewMobile)
select Next value for LogIdSeq, i.StudentID, GETDATE(), CURRENT_USER, d.Surname, 
i.Surname, d.Givename, i.Givename, d.mobile, i.mobile 
from inserted i, deleted d
END

drop TRIGGER TR_DEL_Students
GO

create TRIGGER TR_DEL_Students on StudentTRIG
Instead of DELETE
AS
BEGIN
select 'Students cannot Be Deleted' as [Message]
end   
GO

DELETE from StudentTRIG
GO
select * from StudentTRIG
GO
select * from LogTRIG

insert into StudentTRIG (StudentID, Surname, Givename, mobile)
values (3, 'test', 'testest', 300);
go
select * from StudentTRIG
GO
select * from LogTRIG

update StudentTRIG set 
surname = 'yeet',
givename = 'test',
mobile = 911
where studentID = 3
GO
select * from StudentTRIG
GO
select * from LogTRIG


