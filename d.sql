-- insert demo data to database

-- create stores
insert into stores (name, areaName, latitude, longitude, id) values
("polar1", "tactic", 0, -3, "ps"),
("gw", "greenwich", -1, -2, "gws"),
("upperEq", "equatorUp", 1, 1, "eq1"),
("polarN", "russia", 2, -2, "rs");

-- create customers
insert into customers (name, username, password, email, latitude, longitude,phone, id)
values
-- ("kiptoo", "hk", "Aa48904890plmn", "hk@gmal.com", 0, 2,"0714261231","kiptoohk"),
("nely", "nl", "Aa48904890plmn", "nl@gmal.com", -1, 2,"0714261232", "nelynl"),
("jared", "jrd", "Aa48904890plmn", "jr@gmal.com", 0, 0,"07142601221", "jare12"),
("recude", "rcd", "Aa48904890plmn", "rc@gmal.com", 1, 0,"0714211231", "recudercd"),
("koko", "kk", "Aa48904890plmn", "kk@gmal.com", 2, 2,"071426121", "kokokk"),
("mitch", "mtch", "Aa48904890plmn", "mtch@gmal.com", 3, 3, "714261231", "mitchmtch"),
("kevo", "kv", "Aa48904890plmn", "kv@gmal.com", -1, 3, "071261231", "kevokv"),
("zubayr", "zby", "Aa48904890plmn", "zbyr@gmal.com", -1, 2,"0714296121", "zubayrzby"),
("rasi", "rsi", "Aa48904890plmn", "rs@gmal.com", -1, 1,"07142231", "rasirsi"),
("leslie", "les", "Aa48904890plmn", "les@gmal.com", -1, 0,"071426e12", "leslieles"),
("steve", "stve", "Aa48904890plmn", "steve@gmal.com", 0, 1, "1426w1231", "stevestv"),
("torvalds", "tvrlds", "Aa48904890plmn", "tvrlds@gmal.com", 0, 2,"072we61231", "tvrlds"),
("rose", "ros", "Aa48904890plmn", "ros@gmal.com", 0, 3,"0714261", "roseros"),
("dan", "dante", "Aa48904890plmn", "dante@gmal.com", 1, 0,"07062ew52320", "dantedan"),
("sifa", "esifa", "Aa48904890plmn", "esifa@gmal.com", 1, 1,"070625232", "sifaesifa"),
("moureen", "mr", "Aa48904890plmn", "mr@gmal.com", 1, 2, "07062523","mrch"),
("nerd", "nerdd", "Aa48904890plmn", "nerdd@gmal.com", 1, 3,"0706252", "nnerd"),
("kirchov", "chov", "Aa48904890plmn", "chov@gmal.com", 2, 0, "0706252321","chovr"),
("mill", "meek", "Aa48904890plmn", "meek@gmal.com", 2, 1,"0706252322", "millm"),
("anderson", "andi", "Aa48904890plmn", "anderson@gmal.com", 2, 3,"0706252323", "andi123"),
("smith", "smth", "Aa48904890plmn", "smith@gmal.com", 3, 0,"0706252324", "smith12"),
("bukayo", "bkyo", "Aa48904890plmn", "bukayo@gmal.com", 3, 1,"0706252325", "bukayo12"),
("muhamed", "mhmed", "Aa48904890plmn", "muhammed@gmal.com", 3, 2, "0706252326", "muhammed123"),
("beatrice", "btric", "Aa48904890plmn", "btrice@gmal.com", 3, 3, "0706252327", "btric123"),
("naomi", "naom", "Aa48904890plmn", "naomi@gmal.com", -1, 0,"0706252328", "naomi123"),
("prudence", "prude", "Aa48904890plmn", "prudence@gmal.com", -1, 1,"0706252310", "prude123"),
("joy", "jooy", "Aa48904890plmn", "joy@gmal.com", -1, 2,"0706252311", "joy12"),
("adasa", "adsa", "Aa48904890plmn", "adasa@gmal.com", -1, 3,"0706252312", "adsa12"),
("edwin", "edu", "Aa48904890plmn", "edwin@gmal.com", -2, 0,"0706252313", "edwin"),
("steward", "stwrd", "Aa48904890plmn", "steward@gmal.com", -2, 1,"0706252314", "stw123"),
("gilbert", "gilbt", "Aa48904890plmn", "gilbert@gmal.com", -2, 2,"0706252315", "gilbert12"),
("haron", "haroo", "Aa48904890plmn", "haron@gmal.com", -3, 3, "0706252316","haroo123"),
("varun", "vrn", "Aa48904890plmn", "varun@gmal.com", 0, -1,"0706252317", "varunvrn"),
("lawrence", "lorro", "Aa48904890plmn", "lorro@gmal.com", 1, -1, "0706252318", "lorrro"),
("jerald", "jrld", "Aa48904890plmn", "jerald@gmal.com", 2, -1,"0706252319", "jeraldjrld"),
("moses", "mosee", "Aa48904890plmn", "mosee@gmal.com", 3, -1, "1234", "mos123");

-- create items for sale
insert into groceries (name, description, category, id) 
values
("bananas", "blablabla", "fruits", "bn1"),
("mangos", "blablabla", "fruits", "mn1"),
("cherry", "blablabla", "fruits", "cr1"),
("strawbaries", "blablabla", "fruits", "str1"),
("pumkin", "blablabla", "vegetables", "pm1"),
("spinach", "blablabla", "vigetables", "spn1"),
("kales", "blablabla", "vegatables", "kal1"),
("pork", "blablabla", "meat", "prk1"),
("cow meat", "blablabla", "meat", "cwm1");

-- inventory registry
insert into inventory(storeId, groceryId, stock, price, id)
values
("ps", "bn1", 500, 10.0, "inv1"),
("ps", "mn1", 100, 20.0, "inv2"),
("ps", "cr1", 500, 50.0, "inv3"),
("ps", "str1", 456, 60.6, "inv4"),
("ps", "pm1", 20, 100, "inv5"),
("ps", "spn1", 500, 30.0, "inv6"),
("gws", "cwm1", 600.8, 450, "inv7"),
("gws", "prk1", 500, 10, "inv8"),
("gws", "kal1", 500, 10.0, "inv9"),
("gws", "cr1", 500, 10.0, "inv10"),
("gws", "spn1", 500, 10.0, "inv11"),
("eq1", "spn1", 500, 10.0, "inv12"),
("eq1", "cr1", 500, 10.0, "inv13"),
("eq1", "prk1", 500, 10.0, "inv14"),
("eq1", "cwm1", 500, 10.0, "inv15"),
("rs", "prk1", 500, 10.0, "inv16"),
("rs", "cwm1", 500, 10.0, "inv17"),
("rs", "cr1", 500, 10.0, "inv18"),
("rs", "pm1", 500, 10.0, "inv19");

-- delivery pple
insert into delivery(nationalId, name, username, password, email, phone, latitude, longitude, id) 
values
(1, "a", "b", "c", "abc@gmail.cm", "0001", 0, 0, "abc"),
(2, "d", "e", "f", "def@gmail.cm", "0002", 0, 1, "def"),
(3, "g", "h", "i", "ghi@gmail.cm", "0003", 0, 2, "ghi"),
(4, "j", "k", "l", "jkl@gmail.cm", "0004", 0, 3, "jkl"),
(5, "m", "n", "o", "mno@gmail.cm", "0005", -1, 0, "mno"),
(6, "p", "q", "r", "pqr@gmail.cm", "0006", -1, 1, "pqr"),
(7, "s", "t", "u", "stu@gmail.cm", "0007", -1, 2, "stu"),
(8, "v", "w", "x", "vwx@gmail.cm", "0008", -1, 3, "vwx"),
(9, "y", "z", "zz", "yzz@gmail.cm", "0009", 2, 0, "yzz"),
(10, "aa", "bb", "cc", "aabbcc@gmail.cm", "0010", 2, 1, "aabbcc"),
(11, "dd", "ee", "ff", "ddeeff@gmail.cm", "0011", 2, 2, "ddeeff"),
(12, "gg", "hh", "ii", "gghhii@gmail.cm", "0012", 2, 3, "gghhii"),
(13, "jj", "kk", "ll", "jjkkll@gmail.cm", "0013", 3, 0, "jjkkll"),
(14, "mm", "nn", "oo", "mmnnoo@gmail.cm", "0014", -1, 3, "mmnnoo"),
(15, "pp", "qq", "rr", "ppqqrr@gmail.cm", "0015", 2, -3, "ppqqrr"),
(16, "ss", "tt", "uu", "ssttuu@gmail.cm", "0016", -2, -1, "ssttuu");
