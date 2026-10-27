# k8s-baremetal-lab

## ssh接続

`ansible`が接続できるように、各コンテナは`ssh`サーバー機能を有効にしている。  

```console
$ ssh -i .ssh/ansible-ssh-key root@172.20.0.10
```

`known_hosts`にサーバーの公開鍵を保存したくない場合は以下

```console
$ ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@172.20.0.10
```

## コンテナ再作成時の注意点

### SSH接続時にホスト鍵エラーが出る場合

コンテナを再作成すると`SSH`ホスト公開鍵が再生成される。  
その際、　鍵検証のチャレンジレスポンスで以下のようなエラーが発生することがある。

```text
$ ssh -i .ssh/ansible-ssh-key root@172.20.0.10
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
IT IS POSSIBLE THAT SOMEONE IS DOING SOMETHING NASTY!
Someone could be eavesdropping on you right now (man-in-the-middle attack)!
It is also possible that a host key has just been changed.
The fingerprint for the ED25519 key sent by the remote host is
SHA256:1zJAKupl1B0wyQyjdaj0kUvkV/3x3cgR92fTAywV6k0.
Please contact your system administrator.
Add correct host key in /home/vscode/.ssh/known_hosts to get rid of this message.
Offending ECDSA key in /home/vscode/.ssh/known_hosts:4
  remove with:
  ssh-keygen -f "/home/vscode/.ssh/known_hosts" -R "172.20.0.10"
Host key for 172.20.0.10 has changed and you have requested strict checking.
Host key verification failed.
```

既存のホスト鍵情報を削除して再登録すること。

```console
$ ./tools/update-known-hosts 172.20.0.10 172.20.0.11 172.20.0.12
```

> `ssh-keyscan`は`ssh-keyscan -H ...`としてハッシュ化した方がよい。  
> 今は練習環境なのでわかりやすさを重視してハッシュ化しない方法を取る。

## 疎通確認

sshサーバーへの疎通確認は以下で行う。

```console
$ ansible all -i inventory.yaml -u root --private-key .ssh/ansible-ssh-key -m raw -a "echo OK"
```
