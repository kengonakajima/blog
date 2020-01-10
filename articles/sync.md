# オンラインゲームにおける同期まわりの用語定義と、同期方法の整理


ゲームの状態の全体を「ゲームプレイ空間」と呼ぶ。
プレイヤーが、リモートプレイヤーとおなじゲームプレイ空間に
自分も参加してると感じるなら、それを「同期の感覚」と呼ぶ。

ゲームのシミュレーションなどの処理をしてゲームプレイ空間を変更するのを、
ゲームを進めると言う。
ゲームを進めるためのコードをゲームロジックと呼ぶ。
ゲームロジックはプレイヤーの入力を受け取ってゲームを進め、結果を画面に描画する。


A, B　2人のプレイヤーがリモートでプレイしている場合。
同期の方法(併用が可能)は、以下のように整理できる。

- 厳密な一致を目指すもの
  - ロールバックなし単純同期
    - Aがmaster, Bがviewer. viewer側のプレイヤーは入力をAに送信し、Aでゲームを進行し、Bに結果を送る。　直列モデル？
    - 入力してから反映までにかかる時間が1RTT(Round Trip Time).
    - ゲームロジックは決定論的でなくてもよい
    - 操作結果が無かったことになることはない
    - ゲームロジックをB側に置かなくてもよい(チート対策が可能)
  - ロールバックあり同期(GGPO)
    - A,Bで独立にゲームを進行し互いに送り合う。
    - 不一致の時はゲーム状態の履歴をさかのぼって調べ、一致するまでロールバックする。
    - ゲームロジックは決定論的でなければならない
    - ゲームプレイ空間全体のシリアライズが毎フレーム可能でなければならない
    - 入力してから反映までにかかる時間が多くの場合0RTT
    - 入力が重なったときは操作結果が無かったことになる(一瞬戻される)
    - ネットワーク遅延が20〜50ms以下ぐらいであればほぼ気にならない
    - 予測入力ができれば少しましにできる
    - 人数が増えると急激に破綻が増える
  - サイド固定上書き同期
    - A,Bで独立にゲームを進行し、互いに変更分を送信し合う。
    - 不一致が起きた時は常にAの状態で上書きしてBに通知するか、条件やイベントの種類をみてどちらかのサイドを優先する(ダメージを受けたほう、とか)。
    - ゲームロジックは決定論的でなくてよい
    - 入力してから反映までにかかる時間が多くの場合0RTT
    - 入力が重なったときは操作結果が無かったことになる(一瞬戻される)
    - 上書きするサイドの決め方次第では完全に公平なゲーム結果にならない(タイマンするゲームに不向き)  
    - 予測入力ができれば少しましにできる
- 厳密な一致を目指さないもの
  - やれるだけ同期
    - A,Bで独立にゲームを進行し互いに送り合う
    - 不一致を検出すること自体をしない。
    - プログラムが簡単(あたりまえ)
    - 観戦モードのようにプレイしないクライアントなどに向いてる。
  - 最初だけ同期
    - 初期状態だけ同じにする
    - 開始したあとは同期解除状態。
  - 遅い同期
    - 30秒に1回とかWebAPIを用いて最新状態をとってくるだけ(ポケモンGOやIngressのような)

## どう選ぶか

プログラムのめんどくささは、
最初だけ同期＜やれるだけ同期＜ロールバックなし単純同期＜サイド固定上書き同期＜ロールバックあり同期
である。

まず対戦格闘や1vs1の決闘ゲーム、eスポーツ用のガチバトルゲームとかで、
公平な勝負が必要ならばロールバックあり同期が使えるかを考える。
ゲームロジックを決定論的にでき、ゲームプレイ空間全体のサイズが数百倍と以下とか小さく、同時プレイ人数が2〜3人以下で、
遅延が20〜50ms以下ぐらいならいけるかも。

そうではない場合、企画内容が、本格的なリアルタイム対戦ゲームであるかどうかをよく考える。
本格的なリアルタイム対戦ゲームではない場合は、初期状態だけ同期や、
やれるだけ同期、遅い同期で意外と済んでしまう場合がある。


それで済まない場合は本格的なリアルタイム対戦ゲームだと言える。
その場合は、MMORPGのようにゲーム内容のリバースエンジニアリングを厳密に防ぎたい場合、
ゲームロジックをリモート側に置きたくないので、ロールバックなし単純同期を選択する。
それ以外の、クライアント側にロジックを全部置くタイプの場合は、サイド固定上書き同期でOK。

5Gとかでネットワーク遅延が小さくなってくると、同期のためにめんどくさい工夫をする動機が減ってくるかもしれない。

クラウドゲーミングの場合、1:1や1:Nの場合は上記のことを一切考える必要がない。
N:Nの場合は、上記と同じように考える。

オンラインゲームを支える技術第1版では、サイド固定上書き同期についてある程度紙面をとって説明したが、
第2版では、同期方法の選択肢を一覧にして、どんなふうに選んでいくかの考え方を整理してみたい。