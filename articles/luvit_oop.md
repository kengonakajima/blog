luvitにおける OOP の研究
====

メタテーブルを素朴に使って多段階にクラスを継承すると、テーブル探索の回数が段階数に正比例して、懲罰的なコストがかかることが[わかっている](https://github.com/kengonakajima/blog/blob/master/articles/luaoo.md) 。

そのコストを回避する工夫が必要だが、Lua界における決定版のやり方はまだない感じである。

最近luvitのLua側ライブラリで使われるようになったOOPでは、正比例コストを回避してるのだろうか、調べる。

luvit では、lib/luvit/core.lua で Objectを定義していて、冒頭に必要なことが全部書いてある。

まず、Objectを継承するすべてのクラスで、ただひとつのメタテーブルを共有する。そのテーブルがObject.metaである。

<pre>
local Object = {}core.Object = ObjectObject.meta = {__index = Object}</pre>

クラスのインスタンスを作る関数はこれ:<pre>
function Object:create()  local meta = rawget(self, "meta")  if not meta then error("Cannot inherit from instance object") end  return setmetatable({}, meta) -- ←新規割り当て。 からっぽのテーブルにメタテーブルmetaを設定してそれを返す。end
function Object:new(...)  local obj = self:create()  if type(obj.initialize) == "function" then    obj:initialize(...)  end  return objend</pre>
createが新しいメモリ(からっぽのテーブル)を割り当てる実体。
newは、もし initializeという名前の関数が定義されていたら、それを呼び出すだけ。

これでRubyのクラスと同じ使い勝手になっている。

継承するには、Object:extend関数を使う。

<pre>
function Object:extend()  local obj = self:create()  obj.meta = {__index = obj}  return objend
</pre>





luvitでは、
Object -> Emitter -> Handle -> Stream と継承している:
<pre>    local Emitter = Object:extend()
	function Emitter:on(…) 内容  end
    local Handle = Emitter:extend()
    function Handle:addHandlerType(…) 内容 end
    local Stream = Handle:extend()
    function Stream:listen(…) 内容 end
</pre>

Streamのインスタンスがつくられるときはどういう動きになるか。
--[[Creates a new sub-class.    local Square = Rectangle:extend()    function Square:initialize(w)      self.w = w      self.h = h    end]]function Object:extend()  local obj = self:create()  obj.meta = {__index = obj}  return objend
