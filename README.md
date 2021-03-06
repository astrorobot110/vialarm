# Vialarm

"Vialarm" is "cron" like timer in Vim.
Dumb English detail is [below](#dumb-english).

## 日本語

### どう動くの？

1. `:Vialarm start`とタイプして（もしくはvimrcに書いて）Vialarmを起動します。
2. `autocmd hoge User Vialarm_08:15 edit ~/Documents/todo.md` の様にオートコマンドを追加します。
3. 朝のコーヒーを淹れに行っている間にVialarmがtodo.mdを開かせます。

### 詳細

| コマンド                  | 詳細                                                                                      |
|:--------------------------|:------------------------------------------------------------------------------------------|
|`:Vialarm`                 | Vialarmに関するオートコマンドを表示します。                                               |
|`:Vialarm [HH:MM command]` | oneshotのオートコマンドを追加します。コマンドは"vialarm\_oneshot"グループに登録されます。 |
|`:Vialarm start`           | Vialarmを起動します。                                                                     |
|`:Vialarm stop`            | Vialarmを停止します。                                                                     |
|`:Vialarm timer`           | Vialarmが使用しているタイマーに関する情報を表示します。                                   |

#### Vialarmのオートコマンドについて

Vialarmのタイマー登録にはオートコマンドを使用します。

```
autocmd User {vialarm} {command}
```

引数 {vialarm} は `(vialarm|Vialarm)_HH:MM` の様に記述してください。
大文字の**V**ialarmで登録されたコマンドはスタックされるアラームです。指定時刻にVimがバックグラウンドの場合、Vimがフォアグラウンドになった際に起動されます。

## Dumb English

Most Japanese is not well in English... I also am. :(

### How this work?

1. Type `:Vialarm start` ( or write to your vimrc ) to start Vialarm.
2. Add autocmd like `autocmd foo User Vialarm_08:15 edit ~/Documents/todo.md`
3. Vialarm let Vim to open todo.md while you take morning-coffee in your office. ;)

### Details

| Command                   | Description                                               |
|:--------------------------|:----------------------------------------------------------|
|`:Vialarm`                 | Show autocmd about Vialarm.                               |
|`:Vialarm [HH:MM command]` | Make once-ed autocmd. autocmd grouped 'vialarm\_oneshot'. |
|`:Vialarm start`           | Start Vialarm.                                            |
|`:Vialarm stop`            | Stop Vialarm.                                             |
|`:Vialarm timer`           | Show Vialarm timer infomation.                            |

#### autocmd in Vialarm

Vialarm uses autocommand to run alarm.

```
autocmd User {vialarm} {command}
```

{vialarm} args should be `(vialarm|Vialarm)_HH:MM`.
Capped autocommand ( **V**ialarm ) is 'stacked' alarm. If Vim is background at in time, alarm will run while Vim returns to foreground.
