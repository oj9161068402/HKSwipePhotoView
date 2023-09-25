//
//  UIKit+Extension.swift
//  Fitness For Woman
//
//  Created by Mr.Xr on 2022/2/24.
//

import Foundation
import UIKit
import CoreText



// MARK: - 指定位数进行四舍五入操作
extension Double {
    func roundTo(places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension Float {
    func roundTo(places: Int) -> Float {
        let divisor = pow(10.0, Float(places))
        return (self * divisor).rounded() / divisor
    }
}

extension CGFloat {
    func roundTo(places: Int) -> CGFloat {
        let divisor = pow(10.0, CGFloat(places))
        return (self * divisor).rounded() / divisor
    }
}

extension String {
    func textAutoWidth(height:CGFloat, font:UIFont) -> CGFloat {
        let label = UILabel()
        label.text = self
        label.font = font
        label.Kheight = height
        label.sizeToFit()
        return label.Kwidth
    }
    
    func textAutoheight(width:CGFloat, font:UIFont) -> CGFloat {
        let label = UILabel()
        label.text = self
        label.font = font
        label.Kwidth = width
        label.numberOfLines = 0
        label.sizeToFit()
        return label.Kheight
    }
}

extension UIFont {
    static func customFont(size: CGFloat, weight: String = "") -> UIFont {
        return UIFont(name: "Avenir Next \(weight)", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    /// 一级标题 28 号
    static func titleFirstFont() -> UIFont? {
        return UIFont(name: "Avenir Next Demi Bold", size: 28)
    }
    
    /// 二级标题 24 号
    static func titleSecondFont() -> UIFont? {
        return UIFont(name: "Avenir Next Demi Bold", size: 24)
    }
    
    /// 三级标题 16 号
    static func titleThirdFont() -> UIFont? {
        return UIFont(name: "Avenir Next Demi Bold", size: 16)
    }
    
    /// 解释说明 12 号
    static func titleExplainFont() -> UIFont? {
        return UIFont(name: "Avenir Next Medium", size: 12)
    }
    
    /// Tabbar 10 号
    static func titleTabbarButtonFont() -> UIFont? {
        return UIFont(name: "Avenir Next Medium", size: 10)
    }
    
    /// 提示框 14 号
    static func titleTooltipFont() -> UIFont? {
        return UIFont(name: "Avenir Next Medium", size: 14)
    }
}

protocol StoryboardLoadable {}
extension StoryboardLoadable where Self: UIViewController {
    /// 提供 加载方法
    static func loadStoryboard() -> Self {
        return UIStoryboard(name: "\(self)", bundle: nil).instantiateViewController(withIdentifier: "\(self)") as! Self
    }
}

protocol NibLoadable {}
extension NibLoadable {
    static func loadViewFromNib() -> Self {
        return Bundle.main.loadNibNamed("\(self)", owner: nil, options: nil)?.last as! Self
    }
}

protocol RegisterCellFromNib {}
extension RegisterCellFromNib {
    
    static var identifier: String { return "\(self)" }
    
    static var nib: UINib? { return UINib(nibName: "\(self)", bundle: nil) }
}

extension UITableView {
    /// 注册  nib cell 的方法
    func XR_registerNibCell<T: UITableViewCell>(cell: T.Type) where T: RegisterCellFromNib {
        if let nib = T.nib {
            register(nib, forCellReuseIdentifier: T.identifier)
        }
        else {
            register(cell, forCellReuseIdentifier: T.identifier)
        }
    }
    
    /// 注册 cell 的方法
    func XR_registerCell<T: UITableViewCell>(cell: T.Type) where T: RegisterCellFromNib {
        register(cell, forCellReuseIdentifier: T.identifier)
    }
    
    /// 从缓存池池出队已经存在的 cell
    func XR_dequeueReusableCell<T: UITableViewCell>(indexPath: IndexPath) -> T where T: RegisterCellFromNib {
        return dequeueReusableCell(withIdentifier: T.identifier, for: indexPath) as! T
    }
}

extension UICollectionView {
    /// 注册 nib cell 的方法
    func XR_registerNibCell<T: UICollectionViewCell>(cell: T.Type) where T: RegisterCellFromNib {
        if let nib = T.nib {
            register(nib, forCellWithReuseIdentifier: T.identifier)
        }
        else {
            register(cell, forCellWithReuseIdentifier: T.identifier)
        }
        
    }
    
    /// 注册 cell 的方法
    func XR_registerCell<T: UICollectionViewCell>(cell: T.Type) where T: RegisterCellFromNib {
        register(cell, forCellWithReuseIdentifier: T.identifier)
    }
    
    /// 从缓存池池出队已经存在的 cell
    func XR_dequeueReusableCell<T: UICollectionViewCell>(indexPath: IndexPath) -> T where T: RegisterCellFromNib {
        return dequeueReusableCell(withReuseIdentifier: T.identifier, for: indexPath) as! T
    }
    
    /// 注册头部
    func XR_registerSupplementaryHeaderView<T: UICollectionReusableView>(reusableView: T.Type) where T: RegisterCellFromNib {
        // T 遵守了 RegisterCellOrNib 协议，所以通过 T 就能取出 identifier 这个属性
        if let nib = T.nib {
            register(nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: T.identifier)
        } else {
            register(reusableView, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: T.identifier)
        }
    }
    
    /// 获取可重用的头部
    func XR_dequeueReusableSupplementaryHeaderView<T: UICollectionReusableView>(indexPath: IndexPath) -> T where T: RegisterCellFromNib {
        return dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: T.identifier, for: indexPath) as! T
    }
}

extension UIViewController {
    func addChildViewController(_ childVC: UIViewController, toView: UIView) {
        childVC.beginAppearanceTransition(true, animated: false)
        childVC.view.frame = CGRect.init(x: 0, y: 0, width: kScreenW, height: kScreenH)
        toView.addSubview(childVC.view)
        childVC.endAppearanceTransition()
        childVC.didMove(toParent: self)
    }
}

// MARK: - UIStackView
extension UIStackView {
    static func make(axis: NSLayoutConstraint.Axis, distribution:Distribution,  alignment: Alignment, spacing: CGFloat = 0) -> UIStackView {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = axis
        stackView.distribution = distribution
        stackView.alignment = alignment
        stackView.spacing = spacing
        return stackView
    }
}

// MARK: - 避免数组越界
extension Array {
    /// 避免数组越界
    func safeObject(_ index: Int) -> Element? {
        if index < self.count {
            return self[index]
        } else {
            return nil
        }
    }
    
    // 去重
    func filterDuplicates<T: Equatable>(_ filter: (Element) -> T) -> [Element] {
        var result = [Element]()
        for value in self {
            let key = filter(value)
            if !result.map({filter($0)}).contains(key) {
                result.append(value)
            }
        }
        return result
    }
    
    /// 自定义下标写法
    /// subscript用于更方便的访问集合中的数据
    /// indices.contains用于判断索引值是否在区间类
    /// - Parameter index: 索引值
    subscript(safe index:Int) ->Element?{
        if(indices.contains(index)){
            return self[index];
        }else{
            return nil;
        }
    }
    
    
    /// 普通写法
    ///
    /// - Parameter index: 索引值
    /// - Returns:
    func indexSafe(index:Int) ->Element?{
        if(index > 0 && index < count){
            return self[index];
        }
        
        return nil;
    }
}

extension Array where Element : Equatable {
    
    
    /// 获取数组中的指定元素的索引值
    /// - Parameter item: 元素
    /// - Returns: 索引值数组
    func indexes(of item: Element) -> [Int] {
        var indexes = [Int]()
        for index in 0..<count where self[index] == item {
            indexes.append(index)
        }
        return indexes
    }
    
    
    /// 获取元素首次出现的位置
    /// - Parameter item: 元素
    /// - Returns: 索引值
    func firstIndex(of item: Element) -> Int? {
        for (index, value) in lazy.enumerated() where value == item {
            return index
        }
        return nil
    }
    
    
    /// 获取元素最后出现的位置
    /// - Parameter item: 元素
    /// - Returns: 索引值
    func lastIndex(of item: Element) -> Int? {
        return indexes(of: item).last
    }
    
}

//MARK:删除
extension Array where Element : Equatable {
    
    /// 删除数组中的指定元素
    ///
    /// - Parameter object: 元素
    mutating func remove(object:Element) -> Void {
        for idx in self.indexes(of: object).reversed() {
            self.remove(at: idx)
        }
    }
}

/// 二分法插入元素
extension Array where Element: Comparable {
    private func binarySearchIndex(for element: Element) -> Int {
        var min = 0
        var max = count
        while min < max {
            let index = (min+max)/2
            let other = self[index]
            if other == element {
                return index
            } else if other < element {
                min = index+1
            } else {
                max = index
            }
        }
        return min
    }
    
    mutating func binaryInsert(_ element: Element) {
        insert(element, at: binarySearchIndex(for: element))
    }
}


// MARK: - NSObject
extension NSObject {
    
    // MARK:返回className
    var ClassName:String {
        get{
            let name = type(of: self).description()
            if(name.contains(".")){
                return name.components(separatedBy: ".")[1];
            } else {
                return name;
            }
        }
    }
}



enum Weekday: String, CaseIterable {
    case Sun, Mon, Tue, Wed, Thu, Fri, Sat
}

// MARK: - 日期 获取查询星期几
extension Date {
    /// 向前查询获取第一个星期几，始终考虑today
    func previous(_ weekday: Weekday, considerToday: Bool = false) -> Date {
        return get(.previous,
                   weekday,
                   considerToday: considerToday)
    }
    
    /// 查询获取direction方向的第一个星期几，始终考虑today
    func get(_ direction: SearchDirection,
             _ weekDay: Weekday,
             considerToday consider: Bool = false) -> Date {
        
        let dayName = weekDay.rawValue
        
        let weekdaysName = getWeekDaysInEnglish()  ///.map { $0.lowercased() } 转成小写
        
        assert(weekdaysName.contains(dayName), "weekday symbol should be in form \(weekdaysName)")
        
        let searchWeekdayIndex = weekdaysName.firstIndex(of: dayName)! + 1
        
        let calendar = Calendar(identifier: .gregorian)
        
        if consider && calendar.component(.weekday, from: self) == searchWeekdayIndex {
            return self
        }
        
        
        var nextDateComponent = calendar.dateComponents([.yearForWeekOfYear,.weekOfYear,.hour, .minute, .second], from: self)
        nextDateComponent.weekday = searchWeekdayIndex
        
        let date = calendar.date(from: nextDateComponent)
        return date!
    }
}

// MARK: Helper methods 中间方法
extension Date {
    static func getWeekDaysInEnglish() -> [String] {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US")
        return calendar.shortWeekdaySymbols
    }
    
    func getWeekDaysInEnglish() -> [String] {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US")
        return calendar.shortWeekdaySymbols
    }
    
    /// 选择的日期查询方向
    enum SearchDirection {
        case next
        case previous
        
        var calendarSearchDirection: Calendar.SearchDirection {
            switch self {
            case .next:
                return .forward
            case .previous:
                return .backward
            }
        }
    }
}

// MARK: - Date
extension Date {
    /// 获取当前 秒级 时间戳since1970 - 10位数
    var timeStamp : String {
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        return "\(timeStamp)"
    }
    
    /// 获取当前 毫秒级 时间戳since1970 - 13位
    var milliStamp : String {
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        let millisecond = CLongLong(round(timeInterval*1000))
        return "\(millisecond)"
    }
    
    /// get current Year
    var currentYear: Int {
        return Int(getDateComponent(dateFormat: "yy"))!
        //return getDateComponent(dateFormat: "yyyy")
    }
    
    /// get current Month
    var currentMonth: Int {
        return Int(getDateComponent(dateFormat: "M"))!
        
        //return getDateComponent(dateFormat: "MM")
        
        //return getDateComponent(dateFormat: "MMM")
        
        //return getDateComponent(dateFormat: "MMMM")
    }
    
    /// get current Month Str
    var currentMonthStr: String {
        return getDateComponent(dateFormat: "MMM")
        
        //return getDateComponent(dateFormat: "MM")
        
        //return getDateComponent(dateFormat: "MMM")
        
        //return getDateComponent(dateFormat: "MMMM")
    }
    
    /// /// get current Day
    var currentDay: Int {
        return Int(getDateComponent(dateFormat: "dd"))!
        //return getDateComponent(dateFormat: "dd")
    }
    
    /// 获取en_US_POSIX地区指定格式的日期年月日字符串
    func getDateComponent(dateFormat: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = dateFormat
        return formatter.string(from: self)
    }
    
    static func zeroTimeDate() -> Date {
        let calendar: NSCalendar = NSCalendar.current as NSCalendar
        let unitFlags: NSCalendar.Unit = [
            NSCalendar.Unit.year,
            NSCalendar.Unit.month,
            NSCalendar.Unit.weekday,
            NSCalendar.Unit.day,
            .hour,
            .minute,
            .second]
        var components = calendar.components(unitFlags, from: Date())
        components.hour = 0
        components.minute = 0
        components.second = 0
        let date = calendar.date(from: components)
        return date!
    }
    
    /// 获取当前日期,并将时分秒的值设置为 0,返回一个新日期。
    /// 我们可以在需要以日期来进行比较或计算,忽略时分秒信息的场景使用这个方法
    func zeroTimeDate() -> Date {
        let calendar: NSCalendar = NSCalendar.current as NSCalendar
        let unitFlags: NSCalendar.Unit = [
            NSCalendar.Unit.year,
            NSCalendar.Unit.month,
            NSCalendar.Unit.day,
            .hour,
            .minute,
            .second]
        var components = calendar.components(unitFlags, from: self)
        components.hour = 0
        components.minute = 0
        components.second = 0
        let date = calendar.date(from: components)
        return date!
    }
    
    /// 获取当前系统时间
    func systemDate() -> Date {
        return addingTimeInterval(TimeInterval(NSTimeZone.system.secondsFromGMT()))
    }
    
    /// 获取Date()是星期几
    /// 举例：Mon
    func weekDay() -> String {
        let weekDays = self.getWeekDaysInEnglish()
        let interval = Int(self.timeIntervalSince1970)
        let days = Int(interval/86400) // 24*60*60
        return weekDays[(days - 3) % 7]
    }
    
    /// 获取Date()是星期几
    /// [0,1,2,3,4,5,6] 举例：1
    func getWeekDay() -> Int {
        // 返回一个日历的当前日期的星期，如果不是当前星期进行加减
        let componets = Calendar.autoupdatingCurrent.component(Calendar.Component.weekday, from: self)
        return componets - 1
    }
    
    /// 时间戳Timeinterval转成自定义格式的时间
    func timeIntervalWithforMattetDate(dateFormatStr: String) -> String {
        let dateformatter = DateFormatter()
        //自定义日期格式
        dateformatter.dateFormat = dateFormatStr
        return dateformatter.string(from: self)
    }
    
    /// 比较两个日期的大小  到天
    func compareDateToDate(toDate:Date)  -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let start = formatter.date(from: self.getDateComponent(dateFormat: "yyyy-MM-dd"))
        let end = formatter.date(from: toDate.getDateComponent(dateFormat: "yyyy-MM-dd"))
        return (start!.timeIntervalSince1970 > end!.timeIntervalSince1970) ? true : false
    }
    
    /// 比较两个日期是否是同一天
    func isSameDay(_ otherDay:Date) -> Bool{
        
        let calendar = Calendar.current
        
        let comp1 = calendar.dateComponents([Calendar.Component.year, Calendar.Component.month,Calendar.Component.day], from: self)
        
        let comp2 = calendar.dateComponents([Calendar.Component.year, Calendar.Component.month,Calendar.Component.day], from: otherDay)
        
        return comp1.day == comp2.day && comp1.month == comp2.month  && comp1.year == comp2.year;
    }
    
    /**
     * 获取年、月、日、小时、分钟、秒
     */
    var day: Int {
        return NSCalendar.current.component(Calendar.Component.day, from: self)
    }
    
    var month: Int {
        return NSCalendar.current.component(Calendar.Component.month, from: self)
    }
    
    var year: Int {
        return NSCalendar.current.component(Calendar.Component.year, from: self)
    }
    
    var hour: Int {
        return NSCalendar.current.component(Calendar.Component.hour, from: self)
    }
    
    var minute: Int {
        return NSCalendar.current.component(Calendar.Component.minute, from: self)
    }
    
    var second: Int {
        return NSCalendar.current.component(Calendar.Component.second, from: self)
    }
    
    /// 一年中的总天数
    func daysInYear() -> Int {
        return self.isLeapYear() ? 366 : 365
    }
    
    /// 是否润年
    func isLeapYear() -> Bool {
        let year = self.year
        if (year % 4 == 0 && year % 100 != 0) || year % 400 == 0 {
            return true
        }
        return false
    }
    
    /// 是否在未来
    var isInFuture: Bool {
        return self > Date()
    }
    
    /// 是否在过去
    var isInPast: Bool {
        return self < Date()
    }
    
    /// 是否在本天
    var isInToday: Bool {
        return self.day == Date().day && self.month == Date().month && self.year == Date().year
    }
    
    /// 是否在本月
    var isInMonth: Bool {
        return self.month == Date().month && self.year == Date().year
    }
    
    var isInYear: Bool {
        return self.year == Date().year
    }
    
    func isSameYear(_ date: Date) -> Bool {
        return self.year == date.year
    }
    
    func isSameYearMonth(_ date: Date) -> Bool {
        return self.month == date.month && self.year == date.year
    }
    
    /// 获得当前月份第一天星期几
    var weekdayForMonthFirstday: Int {
        var calendar = Calendar.current
        calendar.firstWeekday = 1
        var comp = calendar.dateComponents([.year, .month, .day], from: self)
        comp.day = 1
        let firstDayInMonth = calendar.date(from: comp)!
        let weekday = calendar.ordinality(of: Calendar.Component.weekday, in: Calendar.Component.weekOfMonth, for: firstDayInMonth)
        return weekday! - 1
    }
    
    /// 获得当前月份一个月总天数
    var daysInMonth: Int {
        return Calendar.current.range(of: Calendar.Component.day, in: Calendar.Component.month, for: self)!.count
    }
    
    /// poor: +-years 获取距当前date相差poor个年的date
    func getOtherYearDate(_ poor: Int) -> Date {
        var dateComponents = DateComponents()
        dateComponents.year = poor
        return Calendar.current.date(byAdding: dateComponents, to: self)!
    }
    
    /// poor: +-months 获取距当前date相差poor个月的date
    func getOtherMonthDate(_ poor: Int) -> Date {
        var dateComponents = DateComponents()
        dateComponents.month = poor
        return Calendar.current.date(byAdding: dateComponents, to: self)!
    }
    
    /// poor: +-days 获取距当前date相差poor个天数的date
    func getOtherDayDate(_ poor: Int) -> Date {
        var dateComponents = DateComponents()
        dateComponents.day = poor
        return Calendar.current.date(byAdding: dateComponents, to: self)!
    }
    
    /// (hours, minutes): +-(hours, minutes) 获取距当前date相差(hour, minute)时间差的date
    func getOtherHourDate(hour: Int, _ minute: Int = 0) -> Date {
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        return Calendar.current.date(byAdding: dateComponents, to: self)!
    }
    
    /// second: +-seconds 获取距当前date相差second秒的date
    func getOtherSecondDate(second: Int) -> Date {
        var dateComponents = DateComponents()
        dateComponents.second = second
        return Calendar.current.date(byAdding: dateComponents, to: self)!
    }
    
    /// 返回当前日期是星期几
    static func currentWeekDay() -> Int {
        let interval = Int(Date().timeIntervalSince1970)
        let days = Int(interval/86400) // 24*60*60
        let weekday = ((days + 4)%7+7)%7
        return weekday == 0 ? 7 : weekday
    }
    
    func checkProductDate() -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        let endDate = formatter.date(from: "2020-12-31")
        /// 当前日期 - 结束日期
        let days = self.daysBetweenDate(toDate: endDate!)
        
        if !(days >= 0) {
            // 已经结束
            return true;
        } else {
            // 还未结束
            return false;
        }
    }
    
    func daysBetweenDate(toDate: Date) -> Int {
        let components = Calendar.current.dateComponents([.day], from: toDate, to: self)
        return components.day ?? 0
    }
}

/// 自定义有效小数位
extension BinaryFloatingPoint where Self: CustomStringConvertible{
    /// 数字类型文本
    ///
    /// 可自定义有效小数位
    /// example:
    ///    var num: Float = 8.0
    ///    num.ec_description()     //"8"
    ///
    ///    num = 8.100
    ///    num.ec_description()     //"8.1"
    ///
    ///    num = 8.888
    ///    num.ec_description()     //"8.888"
    ///    num.ec_description(significand: 2)   //"8.89"
    ///
    /// - parameter significand: 小数的有效位数
    
    func ec_description(significand:Int? = nil) -> String{
        let number = Int(self)
        if Self(number) == self { return number.description }
        guard let significand = significand else { return self.description }
        return String(format: "%.\(significand)f", self as! CVarArg)
    }
}


extension Int64 {
    // 秒转换成00:00:00格式
    var convertTimeToString: String {
        let secounds = TimeInterval.init(self)
        var Min = Int(secounds / 60)
        let Sec = Int(secounds.truncatingRemainder(dividingBy: 60))
        var Hour = 0
        if Min >= 60 {
            Hour = Int(Min / 60)
            Min = Min - Hour * 60
            return String(format: "%02d:%02d:%02d", Hour, Min, Sec)
        }
        return String(format: "%02d:%02d", Min, Sec)
    }
}

extension Int {
    // 秒转换成00:00:00格式
    var convertTimeToString: String {
        let secounds = TimeInterval.init(self)
        var Min = Int(secounds / 60)
        let Sec = Int(secounds.truncatingRemainder(dividingBy: 60))
        var Hour = 0
        if Min >= 60 {
            Hour = Int(Min / 60)
            Min = Min - Hour * 60
            return String(format: "%02d:%02d:%02d", Hour, Min, Sec)
        }
        return String(format: "%02d:%02d", Min, Sec)
    }
    /// 0.1秒单位的秒数转换成00:00:00:0格式
    static func formatSecondsToHMS(_ smallerSeconds: Int) -> String {
        //xiuu
        let totalSeconds = smallerSeconds / 10
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        let smallerSeconds = smallerSeconds % 10
        return String(format: "%02d:%02d:%02d:%01d", hours, minutes, seconds, smallerSeconds)
    }
    /// 0.1秒单位的秒数转换成00:00:00:0格式
    func formatSecondsToHMS() -> String {
        //xiuu
        let totalSeconds = self / 10
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        let smallerSeconds = self % 10
        return String(format: "%02d:%02d:%02d:%01d", hours, minutes, seconds, smallerSeconds)
    }
}

// MARK: - Properties
extension CGFloat {
    var int: Int {
        return Int(self)
    }

    var double: Double {
        return Double(self)
    }

    var float: Float {
        return Float(self)
    }
}


// MARK: - UITableView
/// 适配 ios11的tabelView的section的高度问题
func adaptTableViewSectionHeight(_ tableView: UITableView) {
    if #available(iOS 11.0, *) {
        tableView.estimatedRowHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
    }
}

/// 适配iOS15 tableView sectionHeaderTopPadding
func adaptTableViewSectionHeaderTopPadding(_ tableView: UITableView) {
    if #available(iOS 15.0, *) {
        tableView.sectionHeaderTopPadding = 0
    }
}

//适配iOS11 的滚动 @available(iOS 11.0, *)
func adaptScrollViewAdjust(_ scrollView :UIScrollView){
    if #available(iOS 11.0, *) {
        scrollView.contentInsetAdjustmentBehavior = .never
    }
}

extension NSObject {
    var theClassName:String{
        return NSStringFromClass(type(of: self))
    }
}
