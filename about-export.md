# Android

- normal mssg

```
  dd/dd/dddd, dd:dd pm - name: mssg
  dd/dd/dddd, dd:dd pm - name: <media>
  \d\d\/\d\d\/\d\d\d?\d?, \d\d?d\d\s?(?:pm|am|PM|AM)? - name: mssg
```

- Include Media

```
  # any file
  dd?/dd?/ddd?d?, dd?/dd pm? - name: file-name (file attached)

  # file with caption
  dd?/dd?/ddd?d?, dd?/dd pm? - name: file-name (file attached)
  caption
```

- Without Media

```
  # img file, and documents
  dd?/dd?/ddd?d?, dd?/dd pm? - name: <Media omitted>

  # contact sharing and may be other
  dd?/dd?/ddd?d?, dd?/dd pm? - name: file-name (file attached)

  # file with caption
  caption will be removed when without media
```

# IOS

- normal mssg

```
  normal mssg            :       [dd/dd/dd, dd?:dd:dd PM] name: mssg
  img file               :       [dd/dd/dd, dd?:dd:dd PM] name: <attached: fileId-filename>
  file                   :       [dd/dd/dd, dd?:dd:dd PM] name: file-name <attached: fileId-filename>
  file with caption      :       [dd/dd/dd, dd?:dd:dd PM] name: file-name <attached: fileId-filename>
                                  caption

  for ios files, there is some unicode character at start and before '<attached':
     \U2003[dd/dd/dd, dd?:dd:dd PM] name: \U2003<attached: fileId-filename>

  \[\d\d\/\d\d\/\d\d, \d\d?:\d\d?:\d\d\s(?:PM|AM)\] name: mssg
```

// to do:
// add date and time
// search based on date
// fix copy and share of contact (.vcf file)
// i think video player not added export chat
