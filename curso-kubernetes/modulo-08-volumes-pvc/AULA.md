# Módulo 08 — Volumes e Persistent Volume Claims

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Diferenciar volume **efêmero** (`emptyDir`) de volume **persistente** (PV/PVC)
- Entender o trio **PV + PVC + StorageClass** (storage como serviço)
- Escolher **access mode** e **reclaim policy** certos
- Persistir dados de um banco mesmo após o pod morrer

## 💣 O problema: pod é mortal, dado não pode ser

Por padrão, **container é stateless**. Você mata o pod, o disco do container some junto. Pra app que só serve HTML estático tudo bem. Pra Postgres, MySQL, MongoDB, upload de usuário... é catástrofe.

Solução: **desacoplar o storage do ciclo de vida do pod**. Pod morre, volume continua, próximo pod monta o mesmo volume e acha os dados lá.

## 🗂️ Tipos de volume — do mais simples ao mais sério

### 1. `emptyDir` — efêmero, compartilhado entre containers
- Criado quando o pod sobe, **destruído quando o pod morre**.
- Vive no node, geralmente em disco (ou RAM se você pedir).
- Útil pra: cache temporário, **compartilhar arquivos entre containers do mesmo pod** (padrão sidecar).

```yaml
volumes:
  - name: cache
    emptyDir: {}
```

Não confunda com persistência. É só "um pendrive que dura o que o pod durar".

### 2. `hostPath` — pasta do node
- Monta um caminho **da máquina host** dentro do pod.
- **Má prática em prod**: se o pod for re-schedulado em outro node, o dado some. Acopla pod ao node.
- Útil pra: ferramentas de sistema (Prometheus lendo `/proc`, agente de log lendo `/var/log`), debug.

```yaml
volumes:
  - name: logs
    hostPath:
      path: /var/log
      type: Directory
```

### 3. `configMap` / `secret` — já vistos no Módulo 7
São volumes também — montam chaves como arquivos. Servem pra configuração, não pra storage de app.

### 4. `persistentVolumeClaim` — o jeito certo
É o que você vai usar em prod. Próxima seção.

## 🪙 PV + PVC + StorageClass — a santíssima trindade

O K8s desacopla **quem oferece storage** de **quem pede storage**.

### PersistentVolume (PV)
Um **pedaço de storage no cluster**. Pode ser:
- Provisionado manualmente pelo admin ("aqui tem 10Gi nesse disco NFS")
- **Provisionado dinamicamente** por uma StorageClass quando alguém pede

Recurso **de cluster** (não tem namespace).

### PersistentVolumeClaim (PVC)
Um **pedido** feito pela aplicação: "quero 1Gi, modo ReadWriteOnce". O K8s casa o PVC com um PV compatível (existente OU recém-criado pela StorageClass).

Recurso **de namespace** (vive junto com o app).

### StorageClass (SC)
Define **como** provisionar storage dinamicamente. Aponta pra um **provisioner**: `kubernetes.io/aws-ebs`, `rancher.io/local-path` (kind), CSI driver de qualquer cloud, etc.

Quando você não especifica `storageClassName` no PVC, ele usa a **default** do cluster. No `kind`, a default é `standard` (local-path), que cria pastinhas no node.

```
Pod  ──monta──►  PVC  ──liga em──►  PV  ──vem de──►  StorageClass ──fala com──►  Provisioner
```

## 🔐 Access modes — quem pode ler/escrever

| Modo | Sigla | Quem usa |
|---|---|---|
| `ReadWriteOnce` | RWO | 1 **node** por vez (vários pods nesse node OK) — disco de bloco (EBS, etc) |
| `ReadOnlyMany` | ROX | Vários nodes só lendo |
| `ReadWriteMany` | RWX | Vários nodes lendo/escrevendo — NFS, CephFS, EFS |
| `ReadWriteOncePod` | RWOP | 1 **pod** só (K8s 1.22+) |

Banco de dados quase sempre é **RWO**. Storage compartilhado entre réplicas é **RWX**.

## ♻️ Reclaim policy — o que fazer quando o PVC some

| Policy | Comportamento |
|---|---|
| `Retain` | Mantém o PV e o dado. Admin tem que limpar/reusar manualmente. Seguro. |
| `Delete` | Apaga o PV **e o storage real** (volume na AWS, etc). Default em SC dinâmica. |
| `Recycle` | Deprecated, esqueça. |

Em **prod, ative Retain pra dados críticos** — `kubectl delete pvc` por engano não vai apagar seu banco.

## 🧪 Como isso funciona no `kind`

O `kind` vem com a StorageClass `standard` (provisioner `rancher.io/local-path`) já configurada como default. Isso significa:

- Você cria um PVC → o cluster provisiona um PV automaticamente em pasta local do node (em prática, `hostPath`).
- Reclaim policy default = `Delete`. PVC deletado → dado some.
- Access mode suportado = `ReadWriteOnce` (single-node mesmo).

Pra estudo é perfeito. Pra prod, troque por EBS/GCE-PD/Azure-Disk/CSI da sua cloud.

## 📋 Cheat sheet

| Comando | O que faz |
|---|---|
| `kubectl get pv` | Lista volumes (cluster-wide) |
| `kubectl get pvc` | Lista pedidos no namespace atual |
| `kubectl get storageclass` (ou `sc`) | Lista classes |
| `kubectl describe pvc NOME` | Por que tá `Pending`? Sai aqui |
| `kubectl get pvc -o wide` | Vê o PV ligado |
| `kubectl delete pvc NOME` | Apaga pedido (e PV, se policy=Delete) |

## 💡 Detalhes que valem ouro
- **PVC `Pending` pra sempre**: 99% das vezes é access mode incompatível, tamanho maior que o PV disponível, ou StorageClass errada. `kubectl describe pvc` conta.
- **Não troque storage de pod via `kubectl edit`** — campos de volume são imutáveis. Apague e recrie (cuidado com a reclaim policy).
- **StatefulSet** (próximo nível) usa `volumeClaimTemplates` pra criar **um PVC por réplica** automaticamente. É como bancos rodam em K8s.
- **Backup é seu**, não do K8s. Volume não é backup.
- **Tamanho é pedido mínimo**: PVC de 1Gi pode receber PV de 5Gi (o provisioner decide). Nem todo provider deixa expandir depois.
- **`subPath`**: monta só uma sub-pasta do volume. Útil pra ter vários apps no mesmo PVC ou pra evitar sobrescrever pasta inteira.

## 🚦 Próximos passos
1. `kind create cluster --name estudo` (se não tem ainda)
2. `kubectl get sc` — confirma que tem a `standard` como default
3. Rode `pratica/comandos.sh`
4. Encare o desafio (Postgres persistente)

## ✅ Auto-verificação
- [ ] Sei diferença entre `emptyDir` e PVC
- [ ] Sei explicar PV vs PVC vs StorageClass
- [ ] Sei escolher access mode certo (RWO/ROX/RWX)
- [ ] Sei por que `Retain` salva sua vida em prod
- [ ] Persisti dado, matei pod, dado continuou lá

Próximo módulo: **StatefulSets** — bancos em K8s de verdade.
