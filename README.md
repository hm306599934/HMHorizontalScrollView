# HMHorizontalScrollView
控件, ScrollView, 缓存, 面向协议

### 通过面向协议编程实现自定义带缓存的横向滑动控件。
通过dataSource配置HMHorizontialView的数据源，HMHorizontialView内部通过复用显示Cell，可以在一次加载多个Cell而不卡顿。
UIScollView可以实现横向滑动的分页显示，但是一次加载过多的内容会出现卡顿，通过复用显示的界面来避免卡顿。并通过仿照UITableView的
dataSource实现面向协议的编程。
