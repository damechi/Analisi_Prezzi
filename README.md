# Analisi Prezzi: Analizza prezzi mercato elettrico

## Contents
- [Introduzione](#Introduzione)
- [Descrizione](#Descrizione)
- [Utilizzo](#Utilizzo)
&nbsp;

### Introduzione
Applicazione scritta in ruby e VBA per scaricare ogni giorno tutti i prezzi del mercato elettrico, e analizzarli attraverso Excel
&nbsp;

### Descrizione
Ho creato questa applicazione perchè avevo l'esigenza di scaricare ogni giorno tutti e prezzi del mercato elettrico, inserirli in un DB, per avere uno storico e poterli analizzare attraverso Excel.
Il programma è composto da due componenti, una che gestisce lo scaricamento quotidiano dei prezzi e l'inserimento dentro un DB, tutti questo viene fatto in automatico attraverso lo schedulder di windows ad orari prestabiliti viene lanciato lo scaricamento dei prezzi, nel caso in cui dopo 4 tentativi lo scaricamento non andasse a buon fine, viene avviata una email per segnalare l'anomalia. Se invece i prezzi sono già stati scaricati il processo viene annullato, questo è possibile grazie ad un tabella di log creata nel DB in cui tengo traccia di ogni scaricamento.
L'utilizzo del programma supporto anche lo scaricamnto in manuale passandogli dei parametri da riga di comando es:
ruby main.rb -f MERCATO -s DATA_INIZIO -e DATA_FINE
La seconda componente del programma serve per interfaciarmi con Excel, in pratica ho creato un'interfaccia via Excel, in cui selezioni i dati che mi interessano e da vba lancio il mio script Ruby che fa le query a DB e compila l'Excel con i dati letti nel DB.
&nbsp;


### Utilizzo
Lo scaricamento dei prezzi è automatico attraverso lo scheduler di windows, nel caso in cui si volesse scaricare i prezzi on demand si può utilizzare l'interfaccia da riga di comando:
```
Usage: main.rb -f MGP -s 21/02/2015 -e 23/02/2015

Options
    -f, --flusso     MGP             Flusso to download
    -s, --startdate  22/01/201       Start date to download
    -e, --enddate    23/01/2015      End date to download
    -h, --help                       Display this screen
```
Se viene lanciato lo script solo con il tipo di mercato lo script di default scarica il D+1 per MGP,MI1,MI2 invece per i mercati MI3,MI4,MI5 viene scaricato il giorno attuale.

Invece per la parte che riguarda l'interfaccia con il DB e l'analisi utilizzo l'interfaccia creata con Excel.

Di seguido un video dimostrativo dell'utilizzo:

[![Analisi Prezzi](https://i3.ytimg.com/vi/VdLypplEPO4/hqdefault.jpg)](https://www.youtube.com/embed/VdLypplEPO4?autoplay=1 "Analisi Prezzi")
