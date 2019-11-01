{{ define "assemblyline.coreService" }}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .component }}
  labels:
    app: assemblyline
    section: core
    component: {{ .component }}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: assemblyline
      section: core
      component: {{ .component }}
  template:
    metadata:
      labels:
        app: assemblyline
        section: core
        component: {{ .component }}
    spec:
      priorityClassName: al-core-priority
      containers:
        - name: {{ .component }}
          image: cccs/assemblyline-core:{{ .Values.coreVersion }}
          imagePullPolicy: Always
          command: ['python', '-m', '{{ .command }}']
          volumeMounts:
            - name: al-config
              mountPath: /etc/assemblyline/
            - name: shutdown-script
              mountPath: /media/stopping/
          lifecycle:
            preStop:
              exec:
                command: ["python", "/media/stopping/log.py"]
          resources:
            requests:
              memory: 128Mi
              cpu: 0.05
            limits:
              memory: 1Gi
              cpu: 1
      volumes:
        - name: al-config
          configMap:
            name: {{ .Release.Name }}-global-config
            items:
              - key: config
                path: config.yml
        - name: shutdown-script
          configMap:
            name: shutdown-script
            items:
              - key: script
                path: log.py
{{ end }}
