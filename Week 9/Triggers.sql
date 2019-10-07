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
INCREMENT by 1;

drop TRIGGER TR_UPD_Students
go
delete from StudentTRIG
GO
delete from LogTRIG
go

Create TRIGGER TR_UPD_Students on StudentTRIG
for insert
not for replication
as
BEGIN
insert into LogTRIG (LogID, StudentID, DateTimeChanged, DBUser, OldSurname,
NewSurname, OldGivename, NewGivename, OldMobile, NewMobile)
values (LogIdSeq.NEXTVAL, null, null, null, null, null, null, null, null, null) 

-- insert into LogTRIG (logID, OldSurname, OldGivename, OldMobile)
-- VALUES (LogIdSeq, null, null, null)
end 
GO

insert into StudentTRIG (StudentID, Surname, Givename, mobile)
values (1, 'jeff', 'jeoph', 000);
go
select * from StudentTRIG
GO
select * from LogTRIG


