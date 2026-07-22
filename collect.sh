#!/bin/sh
# Emits R<TAB>rootpct, C<TAB>localpct, CX<TAB>allpct, then per-filesystem rows:
# S|X<TAB>usedBytes<TAB>-<TAB>mountpoint<TAB>device<TAB>sizeBytes
# X = external (network) filesystems, shown only when the toggle is on.

df -B1 -x tmpfs -x devtmpfs -x efivarfs -x overlay -x squashfs \
   --output=source,fstype,target,used,size 2>/dev/null | tail -n +2 | awk '
{
  if ($1 ~ /^\/dev\// && seen[$1]++) next
  ext = ($2 ~ /^(cifs|smb3?|nfs|nfs4|fuse\.sshfs|davfs)$/) ? 1 : 0
  used[$3]=$4; size[$3]=$5; src[$3]=$1; isext[$3]=ext
  au+=$4; as+=$5
  if (!ext) { lu+=$4; ls+=$5 }
  if ($3=="/") { ru=$4; rs=$5 }
}
END{
  printf "R\t%d\n", (rs>0 ? ru*100/rs : 0)
  printf "C\t%d\n", (ls>0 ? lu*100/ls : 0)
  printf "CX\t%d\n", (as>0 ? au*100/as : 0)
  for (m in used)
    printf "%s\t%d\t-\t%s\t%s\t%d\n", (isext[m] ? "X" : "S"), used[m], m, src[m], size[m]
}'
