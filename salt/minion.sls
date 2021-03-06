{% from "salt/map.jinja" import salt_settings with context %}

# Edits based on https://github.com/saltstack-formulas/salt-formula/issues/136

salt-minion:
{% if salt_settings.install_packages %}
  pkg.installed:
    - name: {{ salt_settings.salt_minion }}
{% endif %}
  file.recurse:
    - name: {{ salt_settings.config_path }}/minion.d
    - template: jinja
    - source: salt://{{ slspath }}/files/minion.d
    - clean: {{ salt_settings.clean_config_d_dir }}
    - exclude_pat: _*
    - context:
        standalone: False
  service.running:
    - enable: True
    - name: {{ salt_settings.minion_service }}
    - require:
      - pkg: salt-minion
  cmd.wait:
    - name: echo service salt-minion restart | at now + 1 minute
    - watch:
{% if salt_settings.install_packages %}
      - pkg: salt-minion
{% endif %}
      - file: salt-minion
      - file: remove-old-minion-conf-file

# clean up old _defaults.conf file if they have it around
remove-old-minion-conf-file:
  file.absent:
    - name: /etc/salt/minion.d/_defaults.conf
