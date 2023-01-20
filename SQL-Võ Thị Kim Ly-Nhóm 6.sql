SELECT * From [Purchasing].[PurchaseOrderDetail];

--- Câu 1: Xuất dữ liệu số lượng sản phẩm bị từ chối nhận hàng để quản lý kinh doanh nắm được thông tin
Select 
[PurchaseOrderID],[ProductID],[UnitPrice],[OrderQty],[ModifiedDate],[DueDate],DATEDIFF(Day,ModifiedDate,DueDate) as LeadtimeOrder,[RejectedQty]
From [Purchasing].[PurchaseOrderDetail]
Where [RejectedQty] > 0
Order By ModifiedDate asc; 

---- Câu 2: Xuất ra dữ liệu bao gồm: tổng số lượng đơn hàng, tổng số sản phẩm giao thành công, tổng giá trị mua theo ID nhân viên, sau đó sắp xếp theo thứ tự giảm dần theo tổng giá trị mua(1đ). Tạo cột ranking thể hiện rank id nhân viên theo tổng giá trị mua giảm dần
With ABC AS (
    Select OH.EmployeeID, Sum(OD.OrderQty) as OrderQty, Sum(OD.ReceivedQty) as ReceivedQty, Sum(OD.LineTotal) as LineTotal
    From [Purchasing].[PurchaseOrderDetail] as OD
    Left Join [Purchasing].[PurchaseOrderHeader] as OH on OD.PurchaseOrderID = OH.PurchaseOrderID 
    Group By OH.EmployeeID) --- xuất ra dữ liệu theo đề yêu cầu và sắp xếp theo thứ tự giảm dần theo tổng giá trị mua
SELECT ABC.EmployeeID, ABC.OrderQty, ABC.ReceivedQty, ABC.LineTotal, rank () over (Order By ABC.LineTotal Desc) as Rank 
From ABC;                   ---Tạo cột ranking thể hiện rank id nhân viên theo tổng giá trị mua giảm dần

--- Câu 3: Xuất ra danh sách những nhân viên từng chuyển bộ phận hoặc nghỉ việc.
SELECT * From [HumanResources].[EmployeeDepartmentHistory];
With EmployedMove As (
    SELECT BusinessEntityID
    From [HumanResources].[EmployeeDepartmentHistory]
    GROUP By BusinessEntityID
    HAVING Count(BusinessEntityID) > 1),
     EmployedQuit As (
    SELECT BusinessEntityID
    From [HumanResources].[EmployeeDepartmentHistory]
    GROUP By BusinessEntityID
    HAVING count(BusinessEntityID) = 1)
Select E.BusinessEntityID, DepartmentID, 'Nhan vien chuyen bo phan' as Note 
From EmployedMove as E
INNER JOIN [HumanResources].[EmployeeDepartmentHistory] as EH On E.BusinessEntityID = EH.BusinessEntityID --- Danh sách nhân viên từng chuyển bộ phận 
Where EH.EndDate is Null
UNION ALL                                                                                                 --- Nối 2 danh sách lại với nhau
SELECT EQ.BusinessEntityID, DepartmentID, 'Nhan vien nghi viec' as Note 
From EmployedQuit as EQ
INNER JOIN [HumanResources].[EmployeeDepartmentHistory] as EH On EQ.BusinessEntityID = EH.BusinessEntityID 
Where EH.EndDate is not Null;                                                                             ---Danh sách nhân viên nghỉ việc  