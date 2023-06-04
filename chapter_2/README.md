# 第2章 "足し算と引き算"

第1章では数字を受け取って数字を表示する電卓(?)をつくりました。第2章では足し算と引き算の実装をします。

chapter_2ディレクトリのなかの`sample.y`をコピーして`calc.y`を作りましょう。

```shell
$ cp sample.y calc.y
```

第1章で実装した状態なのでruleは以下のようになっています。

```ruby
rule
  program: NUMBER { p "Input is #{val[0]}" }
         ;

end
```

足し算というのは数値と数値を'+'したものなので以下のように変更してみましょう。

```ruby
rule
  program: NUMBER '+' NUMBER { p val }
         ;

end
```

いつものように`rake`してできたファイルを実行します。`1 + 2`や`2 + 3`を入力すると`[1, "+", 2]`のように配列が表示されます。配列の中身は`[左のNUMBERの値, '+', 右のNUMBERの値]`になっています。

```shell
$ rake
Compiling parser ...

$ ruby calc.rb
Enter the formula:
1 + 2
[1, "+", 2]

Enter the formula:
2 + 3
[2, "+", 3]

Enter the formula:
q
Bye!
```

ここでは実際に足し算をした結果を表示しましょう。

```ruby
rule
  program: NUMBER '+' NUMBER { p "#{val[0]} + #{val[2]} = #{val[0] + val[2]}" }
         ;

end
```

rakeしてファイルを実行します。`1 + 2`や`2 + 3`入力するとうまく表示されています。

```shell
$ rake
Compiling parser ...

$ ruby calc.rb
Enter the formula:
1 + 2
"1 + 2 = 3"

Enter the formula:
2 + 3
"2 + 3 = 5"

Enter the formula:
1

parse error on value "$end" ($end)

Enter the formula:
q
Bye!
```

ここで`1`だけを入力してみるとエラーになってしまいます。第1章で定義したルールを消して`program`は`NUMBER '+' NUMBER`というルールだけにしたので数字1つだけという入力は正しくない入力になってしまっています。`|`を書くことで複数のルールを記述できるので、直しましょう。

```ruby
rule
  program: NUMBER '+' NUMBER { p "#{val[0]} + #{val[2]} = #{val[0] + val[2]}" }
         | NUMBER { p "Input is #{val[0]}" }
         ;

end
```

今度はちゃんと`1 + 2`も`1`もパースできています。

```shell
$ rake
Compiling parser ...

$ ruby calc.rb
Enter the formula:
1 + 2
"1 + 2 = 3"

Enter the formula:
1
"Input is 1"

Enter the formula:
2 - 1
"Input is 2"

parse error on value "-" (error)

Enter the formula:
q
Bye!
```

## 演習: 2-1 引き算を実装せよ

ヒント: `|` をつかって複数のルールを定義することができる。

```ruby
rule
  program: NUMBER '+' NUMBER { p "#{val[0]} + #{val[2]} = #{val[0] + val[2]}" }
         | NUMBER '-' NUMBER { p "#{val[0]} - #{val[2]} = #{val[0] - val[2]}" }
         | NUMBER { p "Input is #{val[0]}" }
         ;

end
```

```shell
$ rake
Compiling parser ...

$ ruby calc.rb
Enter the formula:
1 + 2
"1 + 2 = 3"

Enter the formula:
2
"Input is 2"

Enter the formula:
3 - 1
"3 - 1 = 2"

Enter the formula:
q
Bye!
```

## 発展的な内容

### semantic value (意味値)

文法のルールについて考えるときは`1`も`123`もどちらも数値(NUMBER)で、その具体的な値について考える必要はありません。`1 + 2`も`100 + 200`もどちらも`NUMBER '+' NUMBER`という足し算です。一方で電卓が実際に計算するさいにはNUMBERの具体的な値が必要です。この"記号の値"のことをsemantic value (意味値)といいます。raccの場合、ブロック内では`val`という配列からsemantic valueを取得することができます。

```
NUMBER '+' NUMBER (記号)
  1     +    2    (semantic value)
```

### action (アクション)

ここまで説明せずにrubyのコードを書いてきましたが、ルールの最後についている`{...}`の部分をアクションといいます。`NUMBER '+' NUMBER`が揃ったタイミングでこのアクションに書かれたコードが実行される仕組みになっています。

```
program: NUMBER '+' NUMBER { p "#{val[0]} + #{val[2]} = #{val[0] + val[2]}" }
                           ^~~~~~~~ アクション
```
