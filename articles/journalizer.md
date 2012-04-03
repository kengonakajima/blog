Journalizer : private repoでの活動を自動的に抜粋して公開する
====

githubのプライベートレポジトリに対するコミットの状況を、自動的にフィルタして、一般公開し続けるだけのWebサービス “Journalizer” を試しに作ってみたので、公開します。

<img alt="journalizer_ss.png" src="https://github.com/kengonakajima/blog/raw/master/articles/journalizer_ss.png">


[http://journalizer.net/](http://journalizer.net/)

使い方は、githubのレポジトリごとの設定にある “Post-Receive Hook” に、プッシュ通知先のURLを書き、サイトでgithub経由のログインをするだけです。

これだけでgithubからプッシュを受けて、コミットの内容を解析し、自動的にジャーナルを更新します。いまは過去1週間分を見れます。

自分のレポジトリでの活動はこんなかんじ : [http://journalizer.net/kengonakajima](http://journalizer.net/kengonakajima)

自分の場合は、githubでの活動は95%以上がプライベートレポジトリなので、OSSに限って公開されるいまのgithubの仕様だと、ほとんど動きがないように見えるので、おもしろくないのです。ゲーム開発が主体だと、こうなりがち。

そこで Journalizerを使うと、githubに投げられたpatchやファイル名の内容に対して最低限のパターンマッチをしてフィルタしたり、コミットメッセージを含めたり含めなかったり、自分なりに設定をして公開することができます。

これで自分にプレッシャーをかけてコードやコメントの質を高めていける。かも。

まずは実験をしてみて、実際の役に立つか見てみます。それで、自分がフォローしたいようなユーザが何人か出てきたら、フォローしたりといった機能を付け加えてもいいかもしれません。

ぜひ試してみてください。