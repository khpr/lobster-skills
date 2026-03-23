# S&P 500 信任來源池

格式：名稱 | URL | RSS | 分類 | 驗證日期 | 備註
解析規則：以 `|` 分隔，跳過註解行（#）和空行，腳本只讀 `- ` 開頭的行

## 科技與 AI

- 駭客新聞（Hacker News） | https://news.ycombinator.com/ | https://news.ycombinator.com/rss | tech | 2026-03-05 | 更新即時，社群討論品質高 [lang:en]
- ArXiv AI | https://arxiv.org/list/cs.AI/recent | http://export.arxiv.org/api/query?search_query=cat:cs.AI&sortBy=submittedDate&sortOrder=descending&max_results=30 | tech | 2026-03-05 | Atom API，學術論文首選 [lang:en]
- TechCrunch AI | https://techcrunch.com/category/artificial-intelligence/ | https://techcrunch.com/category/artificial-intelligence/feed/ | tech | 2026-03-05 | AI 專屬 RSS，WordPress 站 [lang:en]
- iThome | https://www.ithome.com.tw/ | https://www.ithome.com.tw/rss | tech | 2026-03-05 | 台灣本地 IT/資安新聞 [lang:zh-tw]
- MIT 科技評論（MIT Technology Review） | https://www.technologyreview.com/ | https://www.technologyreview.com/feed | tech | 2026-03-05 | 深度科技評論，RSS 穩定 [lang:en]
- 連線雜誌（Wired） | https://www.wired.com/ | https://www.wired.com/feed/rss | tech | 2026-03-05 | 全站 RSS，需關鍵字過濾 AI 文章 [lang:en]
- 賽門·威利森的網誌（Simon Willison's Weblog） | https://simonwillison.net/ | none | tech | 2026-03-05 | 無 RSS，web_fetch 穩定，LLM 實務高品質 [lang:en]
- 朝向數據科學（Towards Data Science） | https://towardsdatascience.com/ | https://towardsdatascience.com/feed/ | tech | 2026-03-05 | ML/DS 實務文章，RSS 穩定 [lang:en]

## 社群討論

- r/MachineLearning | https://www.reddit.com/r/MachineLearning/ | https://www.reddit.com/r/MachineLearning/.rss | community | 2026-03-05 | 主頁需登入，RSS 可用 [lang:en]
- r/LocalLLaMA | https://www.reddit.com/r/LocalLLaMA/ | https://www.reddit.com/r/LocalLLaMA/.rss | community | 2026-03-05 | 本地 LLM 社群，RSS 可用 [lang:en]

## 財經（英文）

- NBC 商業新聞（NBC News Business） | https://www.nbcnews.com/business | https://www.nbcnews.com/feed | finance | 2026-03-08 | 主流媒體，署名完整，即時更新，有事實查核機制 [lang:en]

## 財經（日文）

- 鑽石線上（Diamond Online） | https://diamond.jp/ | none | finance | 2026-03-08 | 週刊ダイヤモンド數位版，百年品牌，原創調查報導，日更 [lang:ja]
- 野村 WealthStyle | https://www.nomura.co.jp/wealthstyle/ | none | finance | 2026-03-08 | 野村分析師專欄，署名+履歷，引用規範，券商立場需注意 [lang:ja]
- 三井住友 DS | https://www.smd-am.co.jp/market/ | none | finance | 2026-03-08 | 機構研究，具名分析師，數據嚴謹，日更 [lang:ja]

## 財經（中文）

- 動區動趨 | https://www.blocktempo.com/ | https://www.blocktempo.com/feed/ | finance | 2026-03-08 | 區塊鏈+總經，原創+編譯，引用明確，日更 [lang:zh-tw]
- 富達台灣 | https://www.fidelity.com.tw/ | none | finance | 2026-03-08 | 全球資管機構，專業研究報告，合規嚴謹 [lang:zh-tw]

## 文化與影視

- 好萊塢記者報（Hollywood Reporter） | https://www.hollywoodreporter.com/ | https://www.hollywoodreporter.com/feed/ | film | 2026-03-09 | 好萊塢產業核心媒體，獎季分析首選 [lang:en]
- 綜藝報（Variety） | https://variety.com/ | https://variety.com/feed/ | film | 2026-03-09 | 與 THR 並列好萊塢雙壁，票房+產業+評論 [lang:en]
- 獨立電線（IndieWire） | https://www.indiewire.com/ | https://www.indiewire.com/feed/ | film | 2026-03-09 | 獨立電影+影展+導演深度，Penske 旗下 [lang:en]
- 滾石雜誌電影（Rolling Stone Film） | https://www.rollingstone.com/tv-movies/ | https://www.rollingstone.com/tv-movies/feed/ | film | 2026-03-09 | 奧斯卡研究驗證，導演專訪品質高 [lang:en]
- 紐約客文化（The New Yorker Culture） | https://www.newyorker.com/culture | none | film | 2026-03-09 | 導演/演員深度 profile，長文品質頂級，需 web_fetch [lang:en]
- GQ 娛樂（GQ Entertainment） | https://www.gq.com/entertainment | none | film | 2026-03-09 | 幕後製作專題，奧斯卡研究驗證 [lang:en]
- 釀電影 | https://vocus.cc/filmaholic/home | none | film | 2026-03-09 | 台灣影評社群，繁中深度影評 [lang:zh-tw]
- 報導者 | https://www.twreporter.org/ | https://www.twreporter.org/a/rss2.xml | culture | 2026-03-09 | 台灣深度新聞+文化專題，非營利獨立媒體 [lang:zh-tw]

## 人文社科

- 端傳媒 | https://theinitium.com/ | none | humanities | 2026-03-09 | 華語深度報導，需訂閱，web_fetch 部分可用 [lang:zh-tw]
- 大西洋月刊（The Atlantic） | https://www.theatlantic.com/ | https://www.theatlantic.com/feed/all/ | humanities | 2026-03-09 | 文化+政治+社會長文，品質頂級 [lang:en]

## 生活
（待驗證）


## ─── awesome-rss-feeds 匯入（2026-03-10）───

## 日本

- 日本時報最新文章（Japan Times latest articles） | https://www.japantimes.co.jp/feed/topstories/ | https://www.japantimes.co.jp/feed/topstories/ | 日本 | 2026-03-10 | awesome-rss-feeds 匯入 [lang:ja]
- 今日日本（Japan Today） | https://japantoday.com/feed | https://japantoday.com/feed | 日本 | 2026-03-10 | awesome-rss-feeds 匯入 [lang:ja]
- BRIDGE 科技與新創情報（BRIDGE（ブリッジ）テクノロジー＆スタートアップ情報） | http://feeds.feedburner.com/SdJapan | http://feeds.feedburner.com/SdJapan | 日本 | 2026-03-10 | awesome-rss-feeds 匯入 [lang:ja]
- 紐約時報日本（NYT > Japan） | https://www.nytimes.com/svc/collections/v1/publish/http://www.nytimes.com/topic/destination/japan/rss.xml | https://www.nytimes.com/svc/collections/v1/publish/http://www.nytimes.com/topic/destination/japan/rss.xml | 日本 | 2026-03-10 | awesome-rss-feeds 匯入 [lang:ja]
- Livedoor 新聞 - 主要話題（ライブドアニュース - 主要トピックス） | https://news.livedoor.com/topics/rss/top.xml | https://news.livedoor.com/topics/rss/top.xml | 日本 | 2026-03-10 | awesome-rss-feeds 匯入 [lang:en]
- 朝日新聞數位（朝日新聞デジタル） | http://rss.asahi.com/rss/asahi/newsheadlines.rdf | http://rss.asahi.com/rss/asahi/newsheadlines.rdf | 日本 | 2026-03-10 | awesome-rss-feeds 匯入 [lang:en]

## 電視

- 電視（TV） | https://www.bleedingcool.com/tv/feed/ | https://www.bleedingcool.com/tv/feed/ | 電視 | 2026-03-10 | awesome-rss-feeds 匯入 [lang:en]
- 電視狂熱（TV Fanatic） | https://www.tvfanatic.com/rss.xml | https://www.tvfanatic.com/rss.xml | 電視 | 2026-03-10 | awesome-rss-feeds 匯入 [lang:en]
- TVLine | https://tvline.com/feed/ | https://tvline.com/feed/ | 電視 | 2026-03-10 | awesome-rss-feeds 匯入 [lang:en]

## 書籍

- 閱讀世界的一年（A year of reading the world） | https://ayearofreadingtheworld.com/feed/ | https://ayearofreadingtheworld.com/feed/ | 書籍 | 2026-03-10 | awesome-rss-feeds 匯入 [lang:en]
- Aestas 書評部落格（Aestas Book Blog） | https://aestasbookblog.com/feed/ | https://aestasbookblog.com/feed/ | 書籍 | 2026-03-10 | awesome-rss-feeds 匯入 [lang:en]
- 書籍暴動（BOOK RIOT） | https://bookriot.com/feed/ | https://bookriot.com/feed/ | 書籍 | 2026-03-10 | awesome-rss-feeds 匯入 [lang:en]
- 科克斯書評（Kirkus Reviews） | https://www.kirkusreviews.com/feeds/rss/ | https://www.kirkusreviews.com/feeds/rss/ | 書籍 | 2026-03-10 | awesome-rss-feeds 匯入 [lang:en]
- 頁面排列 – 新書推薦（Page Array – NewInBooks） | https://www.newinbooks.com/feed/ | https://www.newinbooks.com/feed/ | 書籍 | 2026-03-10 | awesome-rss-feeds 匯入 [lang:en]
- Wokeread | https://wokeread.home.blog/feed/ | https://wokeread.home.blog/feed/ | 書籍 | 2026-03-10 | awesome-rss-feeds 匯入 [lang:en]

## 攝影

- 500px | https://iso.500px.com/feed/ | https://iso.500px.com/feed/ | 攝影 | 2026-03-10 | awesome-rss-feeds 匯入 [lang:en]
- 大照片（Big Picture） | https://www.bostonglobe.com/rss/bigpicture | https://www.bostonglobe.com/rss/bigpicture | 攝影 | 2026-03-10 | awesome-rss-feeds 匯入 [lang:en]
- Canon 傳聞（Canon Rumors） | https://www.canonrumors.com/feed/ | https://www.canonrumors.com/feed/ | 攝影 | 2026-03-10 | awesome-rss-feeds 匯入 [lang:en]
- 光影潛行的攝影（Light Stalking） | https://www.lightstalking.com/feed/ | https://www.lightstalking.com/feed/ | 攝影 | 2026-03-10 | awesome-rss-feeds 匯入 [lang:en]
- Lightroom 密技（Lightroom Killer Tips） | https://lightroomkillertips.com/feed/ | https://lightroomkillertips.com/feed/ | 攝影 | 2026-03-10 | awesome-rss-feeds 匯入 [lang:en]
- PetaPixel | https://petapixel.com/feed/ | https://petapixel.com/feed/ | 攝影 | 2026-03-10 | awesome-rss-feeds 匯入 [lang:en]
- 困在海關（Stuck in Customs） | https://stuckincustoms.com/feed/ | https://stuckincustoms.com/feed/ | 攝影 | 2026-03-10 | awesome-rss-feeds 匯入 [lang:en]


### 主題/Fashion

- 時尚 - ELLE（Fashion - ELLE） | https://www.elle.com/rss/fashion.xml/ | https://www.elle.com/rss/fashion.xml/ | 主題/Fashion | 2026-03-10 | awesome-rss-feeds [lang:en]
- 時尚 | 衛報（Fashion | The Guardian） | https://www.theguardian.com/fashion/rss | https://www.theguardian.com/fashion/rss | 主題/Fashion | 2026-03-10 | awesome-rss-feeds [lang:en]
- 時尚 – 印度時尚部落格（Fashion – Indian Fashion Blog） | https://www.fashionlady.in/category/fashion/feed | https://www.fashionlady.in/category/fashion/feed | 主題/Fashion | 2026-03-10 | awesome-rss-feeds [lang:en]
- FashionBeans 男生時尚與風格（FashionBeans Men's Fashion and Style Feed） | https://www.fashionbeans.com/rss-feed/?category=fashion | https://www.fashionbeans.com/rss-feed/?category=fashion | 主題/Fashion | 2026-03-10 | awesome-rss-feeds [lang:en]
- 時尚人士（Fashionista） | https://fashionista.com/.rss/excerpt/ | https://fashionista.com/.rss/excerpt/ | 主題/Fashion | 2026-03-10 | awesome-rss-feeds [lang:en]
- 紐約時報風格（NYT > Style） | https://rss.nytimes.com/services/xml/rss/nyt/FashionandStyle.xml | https://rss.nytimes.com/services/xml/rss/nyt/FashionandStyle.xml | 主題/Fashion | 2026-03-10 | awesome-rss-feeds [lang:en]
- POPSUGAR 時尚（POPSUGAR Fashion） | https://www.popsugar.com/fashion/feed | https://www.popsugar.com/fashion/feed | 主題/Fashion | 2026-03-10 | awesome-rss-feeds [lang:en]
- 煉油廠 29（Refinery29） | https://www.refinery29.com/fashion/rss.xml | https://www.refinery29.com/fashion/rss.xml | 主題/Fashion | 2026-03-10 | awesome-rss-feeds [lang:en]
- THE YESSTYLIST – 亞洲時尚部落格（THE YESSTYLIST – Asian Fashion Blog – brought to you by YesStyle.com） | https://www.yesstyle.com/blog/category/trend-and-style/feed/ | https://www.yesstyle.com/blog/category/trend-and-style/feed/ | 主題/Fashion | 2026-03-10 | awesome-rss-feeds [lang:en]
- 穿什麼（Who What Wear） | https://www.whowhatwear.com/rss | https://www.whowhatwear.com/rss | 主題/Fashion | 2026-03-10 | awesome-rss-feeds [lang:en]

### 主題/Funny

- 尷尬家庭照（AwkwardFamilyPhotos.com） | https://awkwardfamilyphotos.com/feed/ | https://awkwardfamilyphotos.com/feed/ | 主題/Funny | 2026-03-10 | awesome-rss-feeds [lang:en]
- PHD 漫畫（PHD Comics） | http://phdcomics.com/gradfeed.php | http://phdcomics.com/gradfeed.php | 主題/Funny | 2026-03-10 | awesome-rss-feeds [lang:en]
- 佩妮阿卡德（Penny Arcade） | https://www.penny-arcade.com/feed | https://www.penny-arcade.com/feed | 主題/Funny | 2026-03-10 | awesome-rss-feeds [lang:en]
- 郵政秘密（PostSecret） | https://postsecret.com/feed/?alt=rss | https://postsecret.com/feed/?alt=rss | 主題/Funny | 2026-03-10 | awesome-rss-feeds [lang:en]
- 週六早晨早餐麥片漫畫（Saturday Morning Breakfast Cereal） | https://www.smbc-comics.com/comic/rss | https://www.smbc-comics.com/comic/rss | 主題/Funny | 2026-03-10 | awesome-rss-feeds [lang:en]
- 部落格格（The Bloggess） | https://thebloggess.com/feed/ | https://thebloggess.com/feed/ | 主題/Funny | 2026-03-10 | awesome-rss-feeds [lang:en]
- 每日 WTF（The Daily WTF） | http://syndication.thedailywtf.com/TheDailyWtf | http://syndication.thedailywtf.com/TheDailyWtf | 主題/Funny | 2026-03-10 | awesome-rss-feeds [lang:en]
- 洋蔥報（The Onion） | https://www.theonion.com/rss | https://www.theonion.com/rss | 主題/Funny | 2026-03-10 | awesome-rss-feeds [lang:en]
- xkcd | https://xkcd.com/rss.xml | https://xkcd.com/rss.xml | 主題/Funny | 2026-03-10 | awesome-rss-feeds [lang:en]

### 主題/Sports

- BBC 體育 - 運動（BBC Sport - Sport） | http://feeds.bbci.co.uk/sport/rss.xml | http://feeds.bbci.co.uk/sport/rss.xml | 主題/Sports | 2026-03-10 | awesome-rss-feeds [lang:en]
- 體育新聞 - 天空新聞（Sports News - Latest Sports and Football News | Sky News） | http://feeds.skynews.com/feeds/rss/sports.xml | http://feeds.skynews.com/feeds/rss/sports.xml | 主題/Sports | 2026-03-10 | awesome-rss-feeds [lang:en]
- Sportskeeda | https://www.sportskeeda.com/feed | https://www.sportskeeda.com/feed | 主題/Sports | 2026-03-10 | awesome-rss-feeds [lang:en]
- 雅虎體育（Yahoo! Sports - News, Scores, Standings, Rumors, Fantasy Games） | https://sports.yahoo.com/rss/ | https://sports.yahoo.com/rss/ | 主題/Sports | 2026-03-10 | awesome-rss-feeds [lang:en]
- ESPN | https://www.espn.com/espn/rss/news | https://www.espn.com/espn/rss/news | 主題/Sports | 2026-03-10 | awesome-rss-feeds [lang:en]

### 國家/Brazil

- 聖保羅頁報（Folha de S.Paulo - Em cima da hora - Principal） | https://feeds.folha.uol.com.br/emcimadahora/rss091.xml | https://feeds.folha.uol.com.br/emcimadahora/rss091.xml | 國家/Brazil | 2026-03-10 | awesome-rss-feeds [lang:en]
- UOL | http://rss.home.uol.com.br/index.xml | http://rss.home.uol.com.br/index.xml | 國家/Brazil | 2026-03-10 | awesome-rss-feeds [lang:en]
- 里約時報（The Rio Times） | https://riotimesonline.com/feed/ | https://riotimesonline.com/feed/ | 國家/Brazil | 2026-03-10 | awesome-rss-feeds [lang:en]
- 巴西電線（Brasil Wire） | http://www.brasilwire.com/feed/ | http://www.brasilwire.com/feed/ | 國家/Brazil | 2026-03-10 | awesome-rss-feeds [lang:en]
- 巴西利亞日報（Jornal de Brasília） | https://jornaldebrasilia.com.br/feed/ | https://jornaldebrasilia.com.br/feed/ | 國家/Brazil | 2026-03-10 | awesome-rss-feeds [lang:en]

### 國家/Germany

- 時代線上（ZEIT ONLINE | Nachrichten, Hintergründe und Debatten） | http://newsfeed.zeit.de/index | http://newsfeed.zeit.de/index | 國家/Germany | 2026-03-10 | awesome-rss-feeds [lang:en]
- 法蘭克福匯報最新（Aktuell - FAZ.NET） | https://www.faz.net/rss/aktuell/ | https://www.faz.net/rss/aktuell/ | 國家/Germany | 2026-03-10 | awesome-rss-feeds [lang:en]
- tagesschau.de - 德國電視一台新聞（tagesschau.de - Die Nachrichten der ARD） | http://www.tagesschau.de/xml/rss2 | http://www.tagesschau.de/xml/rss2 | 國家/Germany | 2026-03-10 | awesome-rss-feeds [lang:en]
- 德國之聲（Deutsche Welle） | https://rss.dw.com/rdf/rss-en-all | https://rss.dw.com/rdf/rss-en-all | 國家/Germany | 2026-03-10 | awesome-rss-feeds [lang:en]

### 國家/Indonesia

- 共和報（Republika Online RSS Feed） | https://www.republika.co.id/rss/ | https://www.republika.co.id/rss/ | 國家/Indonesia | 2026-03-10 | awesome-rss-feeds [lang:en]
- 澳洲新聞網（Tribunnews.com） | https://www.tribunnews.com/rss | https://www.tribunnews.com/rss | 國家/Indonesia | 2026-03-10 | awesome-rss-feeds [lang:en]

### 國家/Ireland

- 全部：今日新聞（All: BreakingNews.ie） | https://feeds.breakingnews.ie/bntopstories | https://feeds.breakingnews.ie/bntopstories | 國家/Ireland | 2026-03-10 | awesome-rss-feeds [lang:en]
- 愛爾蘭鏡報（Irish Mirror - Home） | https://www.irishmirror.ie/?service=rss | https://www.irishmirror.ie/?service=rss | 國家/Ireland | 2026-03-10 | awesome-rss-feeds [lang:en]

### 國家/Pakistan

- 快報論壇（The Express Tribune） | https://tribune.com.pk/feed/home | https://tribune.com.pk/feed/home | 國家/Pakistan | 2026-03-10 | awesome-rss-feeds [lang:en]
- 國家報 - 熱門故事（The Nation - Top Stories） | https://nation.com.pk/rss/top-stories | https://nation.com.pk/rss/top-stories | 國家/Pakistan | 2026-03-10 | awesome-rss-feeds [lang:zh-tw]
- 國家新聞（قومی خبریں） | https://jang.com.pk/rss/1/1 | https://jang.com.pk/rss/1/1 | 國家/Pakistan | 2026-03-10 | awesome-rss-feeds [lang:en]
- 國際新聞 - 巴基斯坦（The News International - Pakistan） | https://www.thenews.com.pk/rss/1/1 | https://www.thenews.com.pk/rss/1/1 | 國家/Pakistan | 2026-03-10 | awesome-rss-feeds [lang:en]
- 新聞部落格（News Blog） | https://newsnblogs.com/feed/ | https://newsnblogs.com/feed/ | 國家/Pakistan | 2026-03-10 | awesome-rss-feeds [lang:en]
- 烏爾都點（UrduPoint.com All Urdu News） | https://www.urdupoint.com/rss/urdupoint.rss | https://www.urdupoint.com/rss/urdupoint.rss | 國家/Pakistan | 2026-03-10 | awesome-rss-feeds [lang:en]
- 快報烏爾都（ایکسپریس اردو） | https://www.express.pk/feed/ | https://www.express.pk/feed/ | 國家/Pakistan | 2026-03-10 | awesome-rss-feeds [lang:en]

### 國家/South Africa

- 科技中心（TechCentral） | https://techcentral.co.za/feed | https://techcentral.co.za/feed | 國家/South Africa | 2026-03-10 | awesome-rss-feeds [lang:en]
- 新聞 24 熱門故事（News24 Top Stories） | http://feeds.news24.com/articles/news24/TopStories/rss | http://feeds.news24.com/articles/news24/TopStories/rss | 國家/South Africa | 2026-03-10 | awesome-rss-feeds [lang:zh-tw]
- 目擊者新聞（Eyewitness News | Latest News） | https://ewn.co.za/RSS%20Feeds/Latest%20News | https://ewn.co.za/RSS%20Feeds/Latest%20News | 國家/South Africa | 2026-03-10 | awesome-rss-feeds [lang:en]
- 公民報（The Citizen） | https://citizen.co.za/feed/ | https://citizen.co.za/feed/ | 國家/South Africa | 2026-03-10 | awesome-rss-feeds [lang:en]
- 每日特立獨行者（Daily Maverick） | https://www.dailymaverick.co.za/dmrss/ | https://www.dailymaverick.co.za/dmrss/ | 國家/South Africa | 2026-03-10 | awesome-rss-feeds [lang:en]
- Moneyweb | https://www.moneyweb.co.za/feed/ | https://www.moneyweb.co.za/feed/ | 國家/South Africa | 2026-03-10 | awesome-rss-feeds [lang:en]
- IOL 新聞頻道（IOL section feed for News） | http://rss.iol.io/iol/news | http://rss.iol.io/iol/news | 國家/South Africa | 2026-03-10 | awesome-rss-feeds [lang:en]
- 南非報（The South African） | https://www.thesouthafrican.com/feed/ | https://www.thesouthafrican.com/feed/ | 國家/South Africa | 2026-03-10 | awesome-rss-feeds [lang:en]
- Axios | https://api.axios.com/feed/ | https://api.axios.com/feed/ | 國家/South Africa | 2026-03-10 | awesome-rss-feeds [lang:en]

### 國家/Ukraine

- 烏克蘭獨立新聞社（News Agency UNIAN） | https://rss.unian.net/site/news_eng.rss | https://rss.unian.net/site/news_eng.rss | 國家/Ukraine | 2026-03-10 | awesome-rss-feeds [lang:en]
- 通訊報最新新聞（Последние новости на сайте korrespondent.net） | http://k.img.com.ua/rss/ru/all_news2.0.xml | http://k.img.com.ua/rss/ru/all_news2.0.xml | 國家/Ukraine | 2026-03-10 | awesome-rss-feeds [lang:en]
- 審查網 - 新聞（Цензор.НЕТ - Новости） | https://censor.net.ua/includes/news_ru.xml | https://censor.net.ua/includes/news_ru.xml | 國家/Ukraine | 2026-03-10 | awesome-rss-feeds [lang:en]
- TSN 新聞（Новини на tsn.ua） | https://tsn.ua/rss/full.rss | https://tsn.ua/rss/full.rss | 國家/Ukraine | 2026-03-10 | awesome-rss-feeds [lang:en]
- 烏克蘭真理報（Українська правда） | https://www.pravda.com.ua/rss/ | https://www.pravda.com.ua/rss/ | 國家/Ukraine | 2026-03-10 | awesome-rss-feeds [lang:en]
- 戈登 - 最受歡迎材料（Гордон - Самые популярные материалы） | https://gordonua.com/xml/rss_category/top.html | https://gordonua.com/xml/rss_category/top.html | 國家/Ukraine | 2026-03-10 | awesome-rss-feeds [lang:en]
- 時代周刊（НВ） | https://nv.ua/rss/all.xml | https://nv.ua/rss/all.xml | 國家/Ukraine | 2026-03-10 | awesome-rss-feeds [lang:en]
- 埃斯普雷索電視台（Еспресо - український погляд на світ!） | https://espreso.tv/rss | https://espreso.tv/rss | 國家/Ukraine | 2026-03-10 | awesome-rss-feeds [lang:en]
- 報紙報（Gazeta.ua） | https://gazeta.ua/rss | https://gazeta.ua/rss | 國家/Ukraine | 2026-03-10 | awesome-rss-feeds [lang:en]

### 中文原創（台灣）

- 關鍵評論網 | https://www.thenewslens.com/ | https://www.thenewslens.com/feed | 台灣媒體 | 2026-03-10 | 台灣深度評論 [lang:zh-tw]
- 天下雜誌 | https://www.cw.com.tw/ | https://www.cw.com.tw/RSS/cw.xml | 台灣媒體 | 2026-03-10 | 商業+社會 [lang:zh-tw]
- 商業周刊 | https://www.businessweekly.com.tw/ | none | 台灣媒體 | 2026-03-10 | 商業財經 [lang:zh-tw]
- INSIDE | https://www.inside.com.tw/ | https://www.inside.com.tw/feed | 台灣科技 | 2026-03-10 | 台灣科技新創 [lang:zh-tw]
- 泛科學 | https://pansci.asia/ | https://pansci.asia/feed | 台灣科普 | 2026-03-10 | 科普+心理 [lang:zh-tw]
- 親子天下 | https://www.parenting.com.tw/ | none | 台灣生活 | 2026-03-10 | 育兒教育 [lang:zh-tw]
- 故事 StoryStudio | https://storystudio.tw/ | https://storystudio.tw/feed/ | 台灣人文 | 2026-03-10 | 歷史人文 [lang:zh-tw]
- 女人迷 | https://womany.net/ | none | 台灣生活 | 2026-03-10 | 性別+關係 [lang:en]
- 鏡週刊 | https://www.mirrormedia.mg/ | https://www.mirrormedia.mg/rss/category/news/ | 台灣媒體 | 2026-03-10 | 調查報導 [lang:en]

### 中文原創（簡體）

- 少數派 | https://sspai.com/ | https://sspai.com/feed | 中文科技 | 2026-03-10 | 數位生活+效率工具 [lang:zh-cn]
- 愛范兒 | https://www.ifanr.com/ | https://www.ifanr.com/feed | 中文科技 | 2026-03-10 | 消費科技 [lang:zh-cn]
- 36氪 | https://36kr.com/ | https://36kr.com/feed | 中文新創 | 2026-03-10 | 新創+商業 [lang:zh-cn]
- 品玩 | https://www.pingwest.com/ | https://www.pingwest.com/feed | 中文科技 | 2026-03-10 | 矽谷+科技 [lang:zh-cn]

### 日文原創

- 東洋經濟 | https://toyokeizai.net/ | https://toyokeizai.net/list/feed/rss | 日本商業 | 2026-03-10 | 日本商業深度 [lang:ja]
- NHK 新聞（NHK News） | https://www3.nhk.or.jp/news/ | https://www3.nhk.or.jp/rss/news/cat0.xml | 日本新聞 | 2026-03-10 | 日本公共媒體 [lang:ja]
- ITmedia | https://www.itmedia.co.jp/ | https://rss.itmedia.co.jp/rss/2.0/itmedia_all.xml | 日本科技 | 2026-03-10 | 日本IT [lang:ja]
- 娜塔莉（ナタリー） | https://natalie.mu/ | https://natalie.mu/comic/feed/news | 日本動漫 | 2026-03-10 | 漫畫+音樂+舞台 [lang:en]
- 日經商業（日経ビジネス） | https://business.nikkei.com/ | none | 日本商業 | 2026-03-10 | 日經商業 [lang:ja]


## ─── 中文精選列表匯入（2026-03-10）───

### 中文獨立博客

- OneV's Den | http://onevcat.com | http://onevcat.com/atom.xml | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- Limboy 无网不剩 | https://limboy.me/ | https://feeds.feedburner.com/lzyy | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- 唐巧的技术博客 | https://blog.devtang.com | http://blog.devtang.com/atom.xml | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- bang's blog | https://blog.cnbang.net/ | https://blog.cnbang.net/feed/ | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- Kevin Blog | http://zhowkev.in | http://zhowkev.in/rss | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- I'm TualatriX | http://imtx.me | http://imtx.me/feed/latest/ | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- webfrogs | http://blog.nswebfrog.com/ | http://blog.nswebfrog.com/feed/ | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- 玉令天下的Blog | http://yulingtianxia.com | http://yulingtianxia.com/atom.xml | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:zh-tw]
- 土土哥的技术Blog | http://tutuge.me/ | http://tutuge.me/atom.xml | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- 阮一峰的网络日志 | https://www.ruanyifeng.com/blog/ | https://feeds.feedburner.com/ruanyifeng | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- 酷 壳 - CoolShell.cn | https://coolshell.cn/ | https://coolshell.cn/feed | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- 刘未鹏 Mind Hacks – 思维改变生活 | http://mindhacks.cn/ | http://mindhacks.cn/feed/ | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- 云风的 BLOG | http://blog.codingnow.com/ | http://blog.codingnow.com/atom.xml | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- M-x Chris-An-Emacser | https://chriszheng.science/ | https://chriszheng.science/atom.xml | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- 宋春林 | http://sixf.org/ | http://songchunlin.net/cn/feed/ | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- 虞双齐爱折騰 | https://yushuangqi.com/ | https://yushuangqi.com/index.xml | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- 依云's Blog | https://blog.lilydjwg.me/ | https://blog.lilydjwg.me/posts.rss | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- XiaoHui.com | https://www.xiaohui.com/ | https://www.xiaohui.com/rss/ | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- Caos | http://blog.caos.me/ | http://blog.caos.me/feed | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- 透明思考 | http://gigix.thoughtworkers.org/ | http://gigix.thoughtworkers.org/atom.xml | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- DBA Notes | http://dbanotes.net/ | http://dbanotes.net/feed | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- 思圓筆記 – 促成良性循環 | https://hintsnet.com/pimgeek/ | https://hintsnet.com/pimgeek/feed/ | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- DebugUself with DAMA ;-) | https://du.101.camp/ | https://du.101.camp/atom.xml | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- / 是也乎(￣▽￣) / ZoomQuiet.io | ￣▽￣ | https://blog.zoomquiet.io/feeds/all.atom.xml | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- 小胡子哥的个人网站 | https://www.barretlee.com/entry/ | https://www.barretlee.com/rss2.xml | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- 笨方法学写作 | https://www.cnfeat.com/ | https://www.cnfeat.com/feed.xml | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- 王登科-DK博客 - 布洛芬爱好者 | https://greatdk.com/ | https://greatdk.com/feed | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- Linghao's Blog | https://linghao.io/ | https://linghao.io/feed.xml | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- forecho 的独立博客 | https://blog.forecho.com/ | https://blog.forecho.com/atom.xml | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- Randy's Blog | https://lutaonan.com/ | https://lutaonan.com/rss.xml | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- 范叶亮的博客 - Leo Van's Blog | https://leovan.me/ | https://leovan.me/index.xml | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- ZMonster's Blog | https://www.zmonster.me/ | http://www.zmonster.me/atom.xml | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- Hi, DIYgod | https://diygod.me/ | https://diygod.me/atom.xml | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- Blanboom | https://blanboom.org/ | https://blanboom.org/feed | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- TonyHe | https://www.ouorz.com/ | https://blog.ouorz.com/feed | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- 程序员的喵 | https://catcoding.me/archives/ | https://catcoding.me/atom.xml | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- 学无止境 | http://gtdstudy.com/ | http://gtdstudy.com/index.xml | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- 涛叔 | https://taoshu.in/ | https://taoshu.in/feed.xml | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- This Cute World | https://thiscute.world/ | https://thiscute.world/index.xml | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- 歐雷流 | https://ourai.ws/ | https://ourai.ws/atom.xml | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- 賢民的博客 | https://www.xianmin.org/ | https://www.xianmin.org/index.xml | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- 宇宙的心弦 - 细推物理须行乐 何用浮名绊此身 | https://www.physixfan.com/ | https://www.physixfan.com/feed/ | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- 智识@IdeoBook™ | http://www.ideobook.com/ | http://www.ideobook.com/feed/ | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- Beyond the Void | http://www.byvoid.com/ | http://www.byvoid.com/blog/feed/ | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- 木遥的窗子 | http://blog.farmostwood.net/ | http://blog.farmostwood.net/feed | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- 一座島 - 一座島，一個人，一個世界。 | https://island.shaform.com/zh/ | https://island.shaform.com/zh/index.xml | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- 水八口記 • 記錄當下贈與未來 | https://blog.shuiba.co/ | https://blog.shuiba.co/feed | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- 扫地老僧的Blog | https://doyj.com/ | https://doyj.com/feed/ | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- 扯氮集 -- 上海魏武挥的Blog | http://weiwuhui.com/ | http://weiwuhui.com/feed | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- 卢昌海个人主页 | https://www.changhai.org/ | https://www.changhai.org/feed.xml | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- Home - 阳志平的网志 | https://www.yangzhiping.com/ | https://www.yangzhiping.com/feed.xml | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- 吕小荣 | http://mednoter.com/ | http://mednoter.com/feed.xml | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- huangyang.me | https://blog.huangyang.me/ | https://blog.huangyang.me/feed | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- MrToyy's Blog – 探赜索隐 勾深致远 厚德博学 经济匡时 | http://www.mrtoyy.com/ | http://www.mrtoyy.com/index.php/feed/ | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- 海德沙龍（HeadSalon） | http://headsalon.org/ | http://headsalon.org/feed | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- 土木坛子 | https://tumutanzi.com/ | https://tumutanzi.com/feed | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- 奔跑中的奶酪 | https://www.runningcheese.com/ | https://www.runningcheese.com/feed | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- 乱象，印迹 | http://www.luanxiang.org/blog/ | http://feeds.feedburner.com/yurii | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- zhengziying.com | https://zhengziying.com/ | https://zhengziying.com/feed/ | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- 孤岛客 - 几支无用笔，半打有心人。 | http://www.huangjiwei.com/blog/ | http://www.huangjiwei.com/blog/?feed=rss2 | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- 最好金龟换酒 | http://fz0512.com/ | http://fz0512.com/feed | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- Taiwan 2.0 – 展望一個更美好的台灣 | https://taiwan.chtsai.org/ | https://taiwan.chtsai.org/feed/ | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- Huiris's Blog | http://huiris.com/ | http://huiris.com/feed/ | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- 白板報 | http://www.baibanbao.net/ | http://www.wangpei.net/feed/ | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- 比目魚博客：Bimuyu's Blog | http://www.bimuyu.com/blog/ | http://www.bimuyu.com/blog/rss.xml | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- Elizen - 人间不值得 | https://blog.elizen.me/ | https://blog.elizen.me/feed | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- Neverland – Wherefore art thou? | https://type.cyhsu.xyz/ | https://type.cyhsu.xyz/feed/ | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- 杨钦元 - 博客 | http://yangqinyuan.com/ | http://yangqinyuan.com/feed.xml | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- Jarodise – 數位遊民部落（Jarodise – 数字游民部落 – A Chinese Digital Nomad Blog） | https://jarodise.com/ |  https://jarodise.com/feed/ | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]
- 林林雜語 | https://linlinzzo.top/ |  https://linlinzzo.top/feed/ | 中文獨立博客 | 2026-03-10 | RSS-Renaissance [lang:en]

### 中文新聞媒體

- 路透中文網 | https://cn.reuters.com/ | https://feedx.net/rss/reuters.xml | 中文新聞媒體 | 2026-03-10 | RSS-Renaissance [lang:en]
- 紐約時報中文網 | https://cn.nytimes.com/ | https://feedx.net/rss/nytimes.xml | 中文新聞媒體 | 2026-03-10 | RSS-Renaissance [lang:en]
- FT 中文網 | http://www.ftchinese.com/ | https://feedx.net/rss/ft.xml | 中文新聞媒體 | 2026-03-10 | RSS-Renaissance [lang:en]
- BBC 新聞中文（BBC News 中文） | https://www.bbc.com/zhongwen/simp | https://feedx.net/rss/bbc.xml | 中文新聞媒體 | 2026-03-10 | RSS-Renaissance [lang:en]
- 法國國際廣播電台 | http://cn.rfi.fr/ | https://feedx.net/rss/rfi.xml | 中文新聞媒體 | 2026-03-10 | RSS-Renaissance [lang:en]
- 德國之聲（德国之声） | http://www.dw.com | https://feedx.net/rss/dw.xml | 中文新聞媒體 | 2026-03-10 | RSS-Renaissance [lang:en]
- 俄羅斯衛星通訊社 | http://sputniknews.cn/ | https://feedx.net/rss/sputnik.xml | 中文新聞媒體 | 2026-03-10 | RSS-Renaissance [lang:en]
- 聯合早報 | https://www.zaobao.com.sg/ | https://feedx.net/rss/zaobaotoday.xml | 中文新聞媒體 | 2026-03-10 | RSS-Renaissance [lang:en]
- 朝鮮日報網 | http://cnnews.chosun.com/ | https://feedx.net/rss/chosun.xml | 中文新聞媒體 | 2026-03-10 | RSS-Renaissance [lang:en]
- 共同網 | https://china.kyodonews.net/ | https://feedx.net/rss/kyodo.xml | 中文新聞媒體 | 2026-03-10 | RSS-Renaissance [lang:en]
- 朝日新聞 | https://asahichinese-j.com/whatsnew/ | https://feedx.net/rss/asahi.xml | 中文新聞媒體 | 2026-03-10 | RSS-Renaissance [lang:en]
- 日經中文網 | https://cn.nikkei.com/ | https://feedx.net/rss/nikkei.xml | 中文新聞媒體 | 2026-03-10 | RSS-Renaissance [lang:ja]
- 蘋果日報 | https://hk.news.appledaily.com/daily/international/ | https://feedx.net/rss/appledaily.xml | 中文新聞媒體 | 2026-03-10 | RSS-Renaissance [lang:en]
- 中央社 | http://m.cna.com.tw/list/firstnews | https://feedx.net/rss/cna.xml | 中文新聞媒體 | 2026-03-10 | RSS-Renaissance [lang:en]
- 澎湃新聞 | http://www.thepaper.cn/  | https://feedx.net/rss/thepaper.xml | 中文新聞媒體 | 2026-03-10 | RSS-Renaissance [lang:en]


## ─── AI/Tech 精選列表匯入（2026-03-10）───

### 科技（補充）

- 決策實驗室（The Decision Lab） | https://thedecisionlab.com/feed/ | https://thedecisionlab.com/feed/ | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- 內斯實驗室（Ness Labs） | https://nesslabs.com/feed | https://nesslabs.com/feed | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- 法南街（Farnam Street） | https://fs.blog/feed/ | https://fs.blog/feed/ | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- 週日智慧（The Sunday Wisdom） | https://coffeeandjunk.substack.com/feed | https://coffeeandjunk.substack.com/feed | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- 常識 - Commoncog 部落格（Commonplace - The Commoncog Blog） | https://commoncog.com/blog/rss/ | https://commoncog.com/blog/rss/ | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- 史蒂夫·布蘭克（Steve Blank） | http://steveblank.com/feed/ | http://steveblank.com/feed/ | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- 奇點更近了（The singularity is nearer） | https://geohot.github.io/blog/feed.xml | https://geohot.github.io/blog/feed.xml | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- 蓋·川崎（Guy Kawasaki） | http://guykawasaki.com/feed/ | http://guykawasaki.com/feed/ | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- 隨筆 - 班尼迪克·埃文斯（Essays - Benedict Evans） | http://ben-evans.com/benedictevans?format=rss | http://ben-evans.com/benedictevans?format=rss | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- 第一輪審查（First Round Review） | http://firstround.com/review/feed.xml | http://firstround.com/review/feed.xml | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- 山姆·阿爾特曼（Sam Altman） | http://blog.samaltman.com/posts.atom | http://blog.samaltman.com/posts.atom | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- 陳安德魯（Andrew Chen） | http://andrewchen.co/feed/ | http://andrewchen.co/feed/ | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- 桌子的兩側 - Medium（Both Sides of the Table - Medium） | https://bothsidesofthetable.com/feed | https://bothsidesofthetable.com/feed | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- OnStartups | http://feed.onstartups.com/onstartups | http://feed.onstartups.com/onstartups | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- 產品生活（Product Life） | https://productlife.to/feed | https://productlife.to/feed | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- 非理性繁榮（Irrational Exuberance） | https://lethain.com/feeds/ | https://lethain.com/feeds/ | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- SlashGear | http://feeds.slashgear.com/slashgear | http://feeds.slashgear.com/slashgear | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- VentureBeat | http://venturebeat.com/feed/ | http://venturebeat.com/feed/ | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- The Verge | http://www.theverge.com/rss/full.xml | http://www.theverge.com/rss/full.xml | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- Engadget | http://www.engadget.com/rss-full.xml | http://www.engadget.com/rss-full.xml | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- 亞洲科技（Tech in Asia） | https://feeds2.feedburner.com/PennOlson | https://feeds2.feedburner.com/PennOlson | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- 快速企業（Fast Company）  | http://www.fastcodesign.com/rss.xml | http://www.fastcodesign.com/rss.xml | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- 富比士 - 領導力（Forbes - Leadership） | https://www.forbes.com/leadership/feed/ | https://www.forbes.com/leadership/feed/ | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- 產品狩獵（Product Hunt — The best new products, every day） | http://www.producthunt.com/feed | http://www.producthunt.com/feed | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- 駭客新聞：Show HN（Hacker News: Show HN） | http://hnrss.org/show | http://hnrss.org/show | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- Grab 科技（Grab Tech） | http://engineering.grab.com/feed.xml | http://engineering.grab.com/feed.xml | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- Slack 工程（Slack Engineering） | https://slack.engineering/feed | https://slack.engineering/feed | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- 工程 – GitHub 部落格（Engineering – The GitHub Blog） | http://githubengineering.com/atom.xml | http://githubengineering.com/atom.xml | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- Atlassian 開發者部落格（Atlassian Developer Blog） | https://developer.atlassian.com/blog/feed.xml | https://developer.atlassian.com/blog/feed.xml | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- Facebook 工程（Facebook Engineering） | https://code.facebook.com/posts/rss | https://code.facebook.com/posts/rss | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- Grokking 電子報（Grokking Newsletter） | http://newsletter.grokking.org/?format=rss | http://newsletter.grokking.org/?format=rss | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- eBay 科技部落格（eBay Tech Blog） | http://www.ebaytechblog.com/feed/ | http://www.ebaytechblog.com/feed/ | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- Spotify 工程（Spotify Engineering） | http://labs.spotify.com/feed/ | http://labs.spotify.com/feed/ | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- Twitter 工程（Twitter Engineering） | https://blog.twitter.com/engineering/en_us/blog.rss | https://blog.twitter.com/engineering/en_us/blog.rss | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- Stripe 部落格（Stripe Blog） | https://stripe.com/blog/feed.rss | https://stripe.com/blog/feed.rss | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- Instagram 工程 - Medium（Instagram Engineering - Medium） | https://instagram-engineering.com/feed | https://instagram-engineering.com/feed | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- Cloudflare 部落格（The Cloudflare Blog） | https://blog.cloudflare.com/rss/ | https://blog.cloudflare.com/rss/ | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- 工程 – Asana 部落格（Engineering – The Asana Blog） | https://blog.asana.com/category/eng/feed/ | https://blog.asana.com/category/eng/feed/ | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- Canva 工程部落格 - Medium（Canva Engineering Blog - Medium） | https://engineering.canva.com/rss | https://engineering.canva.com/rss | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- Dropbox 科技（Dropbox Tech） | https://dropbox.tech/feed | https://dropbox.tech/feed | 科技（補充) | 2026-03-10 | curated-list [lang:en]
- WePay 工程部落格（WePay Engineering Blog） | https://wecode.wepay.com/feed.xml | https://wecode.wepay.com/feed.xml | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- 網頁瀏覽器工程（Web Browser Engineering） | https://browser.engineering/rss.xml | https://browser.engineering/rss.xml | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- Spotify 工程（Spotify Engineering） | https://engineering.atspotify.com/feed/ | https://engineering.atspotify.com/feed/ | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- Meta 工程（Engineering at Meta） | https://engineering.fb.com/feed/ | https://engineering.fb.com/feed/ | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- 產品關注（Mind the Product） | https://www.mindtheproduct.com/feed/ | https://www.mindtheproduct.com/feed/ | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- 茱莉亞·埃文斯（Julia Evans） | https://jvns.ca/atom.xml | https://jvns.ca/atom.xml | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- 丹·阿布拉莫夫的 Overreacted 部落格（Dan Abramov's Overreacted Blog RSS Feed） | https://overreacted.io/rss.xml | https://overreacted.io/rss.xml | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- 丹·魯（Dan Luu） | https://danluu.com/atom.xml | https://danluu.com/atom.xml | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- Shopify 工程（Shopify Engineering - Shopify Engineering） | https://shopifyengineering.myshopify.com/blogs/engineering.atom | https://shopifyengineering.myshopify.com/blogs/engineering.atom | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- 喬希·科莫的部落格（Josh Comeau's blog） | https://joshwcomeau.com/rss.xml | https://joshwcomeau.com/rss.xml | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- Uber 工程部落格（Uber Engineering Blog） | https://eng.uber.com/feed/ | https://eng.uber.com/feed/ | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- 潛在創造力的波動 - Stripe CTO 部落格（Flurries of latent creativity - Stripe CTO blog） | https://blog.singleton.io/index.xml | https://blog.singleton.io/index.xml | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- 索菲·阿爾伯特（Sophie Alpert） | https://sophiebits.com/atom.xml | https://sophiebits.com/atom.xml | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- 阿姆加德·馬薩德（Amjad Masad） | https://amasad.me/rss | https://amasad.me/rss | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- Signal 部落格（Signal Blog） | https://signal.org/blog/rss.xml | https://signal.org/blog/rss.xml | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- 喬爾談軟體（Joel on Software） | https://www.joelonsoftware.com/feed/ | https://www.joelonsoftware.com/feed/ | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- 務實的工程師（The Pragmatic Engineer） | https://blog.pragmaticengineer.com/rss/ | https://blog.pragmaticengineer.com/rss/ | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- Nvidia 開發者部落格（Nvidia Developer Blog） | https://developer.nvidia.com/blog/feed | https://developer.nvidia.com/blog/feed | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- 機器學習部落格 | 卡內基美隆大學（Machine Learning Blog | ML@CMU | Carnegie Mellon University） | https://blog.ml.cmu.edu/feed/ | https://blog.ml.cmu.edu/feed/ | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- DeepMind  | https://deepmind.com/blog/feed/basic/ | https://deepmind.com/blog/feed/basic/ | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- 杰·阿拉瑪（Jay Alammar） | https://jalammar.github.io/feed.xml | https://jalammar.github.io/feed.xml | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- 蒸餾（Distill） | http://distill.pub/rss.xml | http://distill.pub/rss.xml | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- Lil’Log | https://lilianweng.github.io/lil-log/feed.xml | https://lilianweng.github.io/lil-log/feed.xml | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- MIT 新聞 - 人工智慧（MIT News - Artificial intelligence） | http://news.mit.edu/rss/topic/artificial-intelligence2 | http://news.mit.edu/rss/topic/artificial-intelligence2 | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- 塞巴斯蒂安·魯德（Sebastian Ruder） | http://ruder.io/rss/index.rss | http://ruder.io/rss/index.rss | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- 柏克萊人工智慧研究部落格（The Berkeley Artificial Intelligence Research Blog） | http://bair.berkeley.edu/blog/feed.xml | http://bair.berkeley.edu/blog/feed.xml | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- 張艾瑞克（Eric Jang） | http://blog.evjang.com/feeds/posts/default?alt=rss | http://blog.evjang.com/feeds/posts/default?alt=rss | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- OpenAI  | https://openai.com/news/engineering/rss.xml | https://openai.com/news/engineering/rss.xml | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- 梯度（The Gradient） | https://thegradient.pub/rss/ | https://thegradient.pub/rss/ | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- 品紅（Magenta） | http://magenta.tensorflow.org/feed.xml | http://magenta.tensorflow.org/feed.xml | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- NLP 新聞（NLP News） | http://newsletter.ruder.io/?format=rss | http://newsletter.ruder.io/?format=rss | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- Google AI 部落格（Google AI Blog） | http://googleresearch.blogspot.com/atom.xml | http://googleresearch.blogspot.com/atom.xml | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- Unite.AI | https://www.unite.ai/feed/ | https://www.unite.ai/feed/ | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- Grammarly 部落格（Grammarly Blog） | https://www.grammarly.com/blog/feed/ | https://www.grammarly.com/blog/feed/ | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- 張艾瑞克（Eric Jang） | https://evjang.com/feed | https://evjang.com/feed | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- 亞馬遜科學主頁（Amazon Science Homepage） | https://www.amazon.science/index.rss | https://www.amazon.science/index.rss | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- PyTorch | https://pytorch.org/feed | https://pytorch.org/feed | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- UX 星球（UX Planet） | https://uxplanet.org/feed | https://uxplanet.org/feed | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- NN/g 最新文章（NN/g latest articles and announcements） | https://www.nngroup.com/feed/rss/ | https://www.nngroup.com/feed/rss/ | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- 設計內部（Inside Design） | http://blog.invisionapp.com/feed/ | http://blog.invisionapp.com/feed/ | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- UX 事務（UXmatters） | https://uxmatters.com/index.xml | https://uxmatters.com/index.xml | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- Smashing Magazine 網頁設計文章（Articles on Smashing Magazine — For Web Designers And Developers） | https://www.smashingmagazine.com/feed/ | https://www.smashingmagazine.com/feed/ | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- UX 集體 - Medium（UX Collective - Medium） | https://uxdesign.cc/feed | https://uxdesign.cc/feed | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- Airbnb 設計（Airbnb Design） | http://airbnb.design/feed/ | http://airbnb.design/feed/ | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- web.dev | https://web.dev/feed.xml | https://web.dev/feed.xml | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- Slack 設計（Slack Design） | https://slack.design/feed/ | https://slack.design/feed/ | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- UX 日報（UX Daily - User Experience Daily） | https://interaction-design.org/rss/site_news.xml | https://interaction-design.org/rss/site_news.xml | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- 心理學部落格（Psychology Blog） | http://www.all-about-psychology.com/psychology.xml | http://www.all-about-psychology.com/psychology.xml | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- 世界各地心理學頭條（Psychology Headlines Around the World） | http://www.socialpsychology.org/headlines.rss | http://www.socialpsychology.org/headlines.rss | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- 鸚鵡螺（Nautilus） | https://nautil.us/rss/all | https://nautil.us/rss/all | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- 蘋果橘子經濟學（Freakonomics） | http://freakonomics.blogs.nytimes.com/feed/ | http://freakonomics.blogs.nytimes.com/feed/ | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- 今日心理學（Psychology Today） | https://www.psychologytoday.com/intl/rss.xml | https://www.psychologytoday.com/intl/rss.xml | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- 神經科學新聞（Neuroscience News） | http://neurosciencenews.com/feed/ | http://neurosciencenews.com/feed/ | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- 神經科學新聞 -- 每日科學（Neuroscience News -- ScienceDaily） | https://sciencedaily.com/rss/mind_brain/neuroscience.xml | https://sciencedaily.com/rss/mind_brain/neuroscience.xml | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- 敏銳大腦（SharpBrains） | http://www.sharpbrains.com/feed/ | http://www.sharpbrains.com/feed/ | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- 廣達雜誌（Quanta Magazine） | http://www.quantamagazine.org/feed/ | http://www.quantamagazine.org/feed/ | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- 自然（Nature） | http://www.nature.com/nature/current_issue/rss | http://www.nature.com/nature/current_issue/rss | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- 科學警報（ScienceAlert） | https://www.sciencealert.com/rss | https://www.sciencealert.com/rss | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- 奇點中心（Singularity Hub） | https://singularityhub.com/feed/ | https://singularityhub.com/feed/ | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- 行銷專家（MarketingProfs）  | http://rss.marketingprofs.com/marketingprofs/daily | http://rss.marketingprofs.com/marketingprofs/daily | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- 快速發芽（Quick Sprout） | http://www.quicksprout.com/feed/ | http://www.quicksprout.com/feed/ | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- 社群媒體審核員（Social Media Examiner | Social Media Marketing） | http://www.socialmediaexaminer.com/feed/ | http://www.socialmediaexaminer.com/feed/ | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- 約翰·埃根（John Egan） | http://jwegan.com/feed/rss/ | http://jwegan.com/feed/rss/ | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- 說服與轉換（Convince and Convert）  | http://www.convinceandconvert.com/feed/ | http://www.convinceandconvert.com/feed/ | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- Hubspot | http://blog.hubspot.com/CMS/UI/Modules/BizBlogger/rss.aspx?tabid=6307&moduleid=8441&maxcount=25 | http://blog.hubspot.com/CMS/UI/Modules/BizBlogger/rss.aspx?tabid=6307&moduleid=8441&maxcount=25 | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- 賽斯·高汀部落格（Seth Godin's Blog）  | http://sethgodin.typepad.com/seths_blog/atom.xml | http://sethgodin.typepad.com/seths_blog/atom.xml | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- Backlinko | http://backlinko.com/feed | http://backlinko.com/feed | 科技（補充） | 2026-03-10 | curated-list [lang:en]
- 哈佛商業評論（HBR.org） | http://feeds.harvardbusiness.org/harvardbusiness/ | http://feeds.harvardbusiness.org/harvardbusiness/ | 科技（補充） | 2026-03-10 | curated-list [lang:en]

### 機器學習

- Statsbot 部落格 - Medium（Blog - Cube Dev - Medium） | https://blog.statsbot.co/feed | https://blog.statsbot.co/feed | 機器學習 | 2026-03-10 | curated-list [lang:en]
- 機器學習精通部落格（Blog - Machine Learning Mastery） | http://machinelearningmastery.com/blog/feed | http://machinelearningmastery.com/blog/feed | 機器學習 | 2026-03-10 | curated-list [lang:en]
- AWS 機器學習部落格（Blog AWS Machine Learning） | https://aws.amazon.com/blogs/machine-learning/feed | https://aws.amazon.com/blogs/machine-learning/feed | 機器學習 | 2026-03-10 | curated-list [lang:en]
- 機器學習製造部落格（Blog Made With ML） | https://madewithml.com/newsletter/ | https://madewithml.com/newsletter/ | 機器學習 | 2026-03-10 | curated-list [lang:en]
- 生產中的機器學習部落格（Blog ML in Production） | https://mlinproduction.com/feed | https://mlinproduction.com/feed | 機器學習 | 2026-03-10 | curated-list [lang:en]
- 機器學習研究進展（Proceedings of Machine Learning Research） | http://proceedings.mlr.press//feed.xml | http://proceedings.mlr.press//feed.xml | 機器學習 | 2026-03-10 | curated-list [lang:en]
- inFERENCe 部落格（Blog inFERENCe） | https://www.inference.vc/rss | https://www.inference.vc/rss | 機器學習 | 2026-03-10 | curated-list [lang:en]
- 約翰·D·庫克部落格（Blog John D. Cook） | https://www.johndcook.com/blog/feed | https://www.johndcook.com/blog/feed | 機器學習 | 2026-03-10 | curated-list [lang:en]
- fast.ai NLP | http://nlp.fast.ai/feed.xml | http://nlp.fast.ai/feed.xml | 機器學習 | 2026-03-10 | curated-list [lang:en]
- NLP 觀眾部落格（NLP The Spectator） | http://blog.shakirm.com/feed | http://blog.shakirm.com/feed | 機器學習 | 2026-03-10 | curated-list [lang:en]
- AI 趨勢（AI Trends） | https://www.aitrends.com/feed | https://www.aitrends.com/feed | 機器學習 | 2026-03-10 | curated-list [lang:en]
- AI 古怪（AI Weirdness） | https://aiweirdness.com/rss | https://aiweirdness.com/rss | 機器學習 | 2026-03-10 | curated-list [lang:en]
- 人工智慧律師（Artificial Lawyer） | https://www.artificiallawyer.com/feed | https://www.artificiallawyer.com/feed | 機器學習 | 2026-03-10 | curated-list [lang:en]
- 人工智慧雜誌 - Medium（Medium - Artificial Intelligence Magazine） | https://becominghuman.ai/feed | https://becominghuman.ai/feed | 機器學習 | 2026-03-10 | curated-list [lang:en]
- AI 論文評選（Papers Review AI） | http://davidstutz.de/feed | http://davidstutz.de/feed | 機器學習 | 2026-03-10 | curated-list [lang:en]
- Seita 的地方部落格（Blog Seita's Place） | https://danieltakeshi.github.io/feed.xml | https://danieltakeshi.github.io/feed.xml | 機器學習 | 2026-03-10 | curated-list [lang:en]
- VITAL 文獻回顧部落格（Blog VITAL Literature Review） | https://vitalab.github.io/feed.xml | https://vitalab.github.io/feed.xml | 機器學習 | 2026-03-10 | curated-list [lang:en]
- 微軟研究（Microsoft Research） | https://www.microsoft.com/en-us/research/feed | https://www.microsoft.com/en-us/research/feed | 機器學習 | 2026-03-10 | curated-list [lang:en]
- 柳在俊的遊樂場部落格（Blog Jaejun Yoo's Playground） | http://jaejunyoo.blogspot.com/feeds/posts/default | http://jaejunyoo.blogspot.com/feeds/posts/default | 機器學習 | 2026-03-10 | curated-list [lang:en]
- RL 週刊（RL Weekly seungjaeryanlee） | https://www.getrevue.co/profile/seungjaeryanlee?format=rss | https://www.getrevue.co/profile/seungjaeryanlee?format=rss | 機器學習 | 2026-03-10 | curated-list [lang:en]
- 少樣本學習部落格（Blog few-shot learning）  | https://mpatacchiola.github.io/blog/feed.xml | https://mpatacchiola.github.io/blog/feed.xml | 機器學習 | 2026-03-10 | curated-list [lang:en]
- Dtransposed 部落格（Blog Dtransposed） | https://dtransposed.github.io/feed.xml | https://dtransposed.github.io/feed.xml | 機器學習 | 2026-03-10 | curated-list [lang:en]

## 心理學 (psych)

- Greater Good Magazine | https://greatergood.berkeley.edu/ | RSS:待校正(/feeds/1失效) | psych | 2026-03-11 | 柏克萊幸福科學中心，原創性高 [lang:en]
- BPS Research Digest | https://www.bps.org.uk/research-digest | RSS:待校正(已遷移) | psych | 2026-03-11 | 英國心理學會研究摘要，學術權威 [lang:en]
- Psychology Today | https://www.psychologytoday.com/ | RSS:待校正(/intl/blog路徑錯) | psych | 2026-03-11 | 心理學主流媒體，作者多為執業心理師 [lang:en]

## 性別議題 (gender)

- The Cut | https://www.thecut.com/ | https://www.thecut.com/rss.xml | gender | 2026-03-11 | 女性視角文化與關係深度報導（待RSS連通驗證） [lang:en]

## 性別議題 (gender) — 續

- Ms. Magazine | https://msmagazine.com/ | https://msmagazine.com/feed/ | gender | 2026-03-11 | 女性主義媒體老牌，RSS 正常 [lang:en]

## 創業 (startup)

- YC Blog | https://www.ycombinator.com/blog | https://www.ycombinator.com/blog/rss.xml | startup | 2026-03-11 | Y Combinator 官方，創業思維首選 [lang:en]
- Indie Hackers | https://www.indiehackers.com/ | RSS:待校正(feed.xml失效) | startup | 2026-03-11 | 獨立創業者社群，高實務價值 [lang:en]
- 創業小聚 | https://meet.bnext.com.tw/ | https://rss.bnextmedia.com.tw/feed/meet/rss | startup | 2026-03-11 | 台灣創業新聞，RSS 已校正至實際 URL [lang:zh-tw]

## 經濟學 (econ)

- Marginal Revolution | https://marginalrevolution.com/ | https://marginalrevolution.com/feed | econ | 2026-03-11 | Tyler Cowen 經濟學部落格，觀點犀利 [lang:en]

## 經濟學 (econ) — 續

- Planet Money (NPR) | https://www.npr.org/sections/money/ | https://feeds.npr.org/510289/podcast.xml | econ | 2026-03-11 | NPR 經濟學 podcast，RSS 正常 [lang:en]

## 人類學 (anthro)

- SAPIENS | https://www.sapiens.org/ | https://www.sapiens.org/feed/ | anthro | 2026-03-11 | 人類學科普媒體，RSS 正常 [lang:en]
- AnthroDendum | https://anthrodendum.org/ | https://anthrodendum.org/index.xml | anthro | 2026-03-11 | 人類學學術部落格，RSS 已校正為 index.xml [lang:en]

## 日本漫畫/動畫 (manga)

- Anime News Network | https://www.animenewsnetwork.com/ | https://www.animenewsnetwork.com/newsroom/rss.xml | manga | 2026-03-11 | 動漫業界新聞基準，RSS 正常 [lang:ja]
- Crunchyroll News | https://www.crunchyroll.com/anime-news | RSS:待校正(news.rss失效) | manga | 2026-03-11 | 官方串流平台，RSS URL 需重找 [lang:ja]
- 電撃オンライン | https://dengekionline.com/ | RSS:待校正(/rss/失效) | manga | 2026-03-11 | 日本動漫遊戲媒體，RSS URL 需重找 [lang:ja]

## 主機遊戲 (gaming)

- Polygon | https://www.polygon.com/ | https://www.polygon.com/feed/ | gaming | 2026-03-11 | 遊戲文化媒體，RSS 已校正為 /feed/ [lang:en]
- Kotaku | https://kotaku.com/ | https://kotaku.com/feed | gaming | 2026-03-11 | 遊戲速報，RSS 已校正為 /feed [lang:en]
- Eurogamer | https://www.eurogamer.net/ | https://www.eurogamer.net/feed | gaming | 2026-03-11 | 歐洲遊戲評論權威，RSS 正常 [lang:en]

## 串流上片 (streaming)

- What's on Netflix | https://www.whats-on-netflix.com/ | https://www.whats-on-netflix.com/feed/ | streaming | 2026-03-11 | Netflix 上架追蹤，RSS 正常 [lang:en]
- Decider | https://decider.com/ | https://decider.com/feed/ | streaming | 2026-03-11 | 串流選片推薦，RSS 正常 [lang:en]

## 育兒 (parenting)

- Aha! Parenting | https://www.ahaparenting.com/ | RSS:待校正(blog/rss.xml失效,已遷移) | parenting | 2026-03-11 | 正向教養方法論，RSS URL 需重找 [lang:en]

## 育兒 (parenting) — 續

- Parents Magazine | https://www.parents.com/ | RSS:待校正(403封鎖) | parenting | 2026-03-11 | 主流育兒媒體，網站正常但 RSS 被封鎖 [lang:en]

## 居家整理 (home)

- Apartment Therapy | https://www.apartmenttherapy.com/ | https://www.apartmenttherapy.com/main.rss | home | 2026-03-11 | 居家設計整理媒體，RSS 正常 [lang:en]
- The Spruce | https://www.thespruce.com/ | RSS:待校正(403封鎖) | home | 2026-03-11 | 居家生活指南，RSS 被 Cloudflare 封鎖 [lang:en]

## 寶可夢卡牌 (tcg)

- PokeBeach | https://www.pokebeach.com/ | RSS:待校正(Cloudflare封鎖) | tcg | 2026-03-11 | PTCG 情報首選，直連被封可改用 curl 繞 [lang:en]
- r/pkmntcg | https://www.reddit.com/r/pkmntcg/ | https://www.reddit.com/r/pkmntcg/.rss | tcg | 2026-03-11 | Reddit 卡牌社群（待連通驗證） [lang:en]

## 兩性戀愛 (dating)

- Gottman Institute Blog | https://www.gottman.com/blog/ | https://www.gottman.com/blog/feed/ | dating | 2026-03-11 | 關係心理學研究機構，RSS 正常 [lang:en]
