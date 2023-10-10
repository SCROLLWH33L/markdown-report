OSID = $(strip $(shell cat osid.txt))
name = OSCP-OS-$(OSID)-Exam-Report

.PHONY: $(name).pdf latex clean zip

$(name).pdf:
	pandoc --defaults src/settings.yaml --output $(name).pdf

latex:
	pandoc --defaults src/settings.yaml --output $(name).tex

clean:
	rm -f pandoc.log
	rm -f $(name)*
