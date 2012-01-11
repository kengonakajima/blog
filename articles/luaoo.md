Luaでのオブジェクト指向のコスト比較
====

クラスのないLuaでは、擬似的にクラスのような仕組みを作って使う。

擬似的なクラスを実現する鉄板の方法は、メタテーブルを使う方法である。
JavaScriptのprototypeのようなもの、と説明されるが、その実態は、
Rubyにおける method_missing に近い仕組みである。
メソッドや演算子(テーブルの要素)が見つからないときに、 __add (加算演算子)とか  __index (メンバ名解決)
とか決まった名前の要素を、あらかじめ指定したテーブルから検索させ、それを使うことができる。

メソッドを定義するにはこう

    Character = {}
    function Character.new(name)
       local obj = {x=0,y=0,name=name}
       return setmetatable( obj,  {__index = Character} )
    end
    function Character.walkTo(self,x,y)
       -- 内容
    end

呼ぶにはこう

    ch = Character.new("steve")
    ch:walkTo(x,y)

クラスを拡張するにはこう

    Player={}
    setmetatable( Player, { __index = Character} )
    function Player.new(name,job)
        local o = Character.new(name)
        o.job = job
        return setmetatable(o, { __index = Player } )
    end


おまじないが多くて、きれいではない。

それを嫌って、JavaScriptでいうCoffeeScriptに対応する、
MoonScriptというのもあるが、CoffeeScriptと同様、「1枚挟まった感じ」
がすきではない。

一方で、メタテーブルを使わずに、テーブルの要素に関数自体を入れて使うだけ、
という小規模向けで気楽な方法も多用される。
この方法は、必要なコードの量が少なくて、凝集してるから見やすい。

定義するにはこう

    function new_Character(name)
       local o = { x=0, y=0, name=name }
       o.walkTo = function(self,x,y)
                     -- 内容
                  end
       return o
    end

呼ぶにはこう

    v = new_Character("steve")
    v:walkTo(x,y)

クラスを拡張するにはこう

    function new_Player(name,job)
       local o = new_Character(name)
       o.job = job
       return o
    end

おまじないがほとんどなくて、見やすい。

しかし、インスタンスを初期化するごとに関数の初期化が発生するため、
この方法は遅いのではないか、と思っていた。

それで、速度を調査してみた。

[lua-oo-speedcomp データ](https://github.com/kengonakajima/lua-oo-speedcomp)

結論としては、2〜3段以上継承をする場合は、メタテーブルを使うほうが遅い。
遅いというか、ほとんど懲罰的なコストがかかってしまう。
これほど遅い原因は、アクセスしたクラスにメソッドがみつからないたびに、
上位のメタテーブルに何度も検索にいくためだ。
だから継承が深くなると、比例したコストがかかる。

また調査では、メタテーブルを使わない単純な方法を使う場合には、
インスタンス初期化時のコストをできるだけ下げるために、
名前つき関数を定義してそれを代入するだけ、という手を使えることもわかった。
あまりきれいではないけど。

遅い原因がわかったので、これでちょっと自信をもって、LuaでOOPができるかもしれない。


さて今後だが。

たとえばLuaJITが、メタテーブルの検索結果をキャッシュして、
2回目以降はそのアドレスを使うようになれば、劇的な高速化が期待できる。
これはそんなに難しくないかもしれない。

しかし、やりたいことの割に、低いところまでいじりすぎな感じだ。

あるいは、自前で、このコストを吸収する「クラスぽいものを実現するためのモジュール」を作れるかもしれない。
ようするに多段階に継承したときにも、同じテーブルにメンバが増えていくようなラッパがあって、
ほぼ定数時間で探索できるテーブルの利点を殺さないようになっていればよい。

ちょっとしたツールでできてしまうかもしれないので、次はそれをやってみよう。
すでに誰かが作っているかも？



