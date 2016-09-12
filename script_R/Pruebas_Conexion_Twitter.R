# instalar librerias
install.packages("twitteR")
install.packages("tm")
install.packages("wordcloud")


# cargar librerias
library(twitteR)
library(NLP)
library(tm)
library(RColorBrewer)
library(wordcloud)


# credenciales de conexion
api_key <- ""
api_secret <- ""

access_toke <- ""
access_toke_secr <- ""

reqURL <- ""
access_token <- ""
auURL <- ""

setup_twitter_oauth(api_key,
                    api_secret,
                    access_toke,
                    access_toke_secr)


# recolecta tweets de @alguien
tweets = userTimeline("MedelPitbull", 3200)

# vuelca la informacion de los tweets a un data frame
df = twListToDF(tweets)

# obtiene el texto de los tweets
txt = df$text

##### inicio limpieza de datos #####
# remueve retweets
txtclean = gsub("(RT|via)((?:\\b\\W*@\\w+)+)", "", txt)
# remove @otragente
txtclean = gsub("@\\w+", "", txtclean)
# remueve simbolos de puntuación
txtclean = gsub("[[:punct:]]", "", txtclean)
# remove números
txtclean = gsub("[[:digit:]]", "", txtclean)
# remueve links
txtclean = gsub("http\\w+", "", txtclean)
##### fin limpieza de datos #####

# construye un corpus
corpus = Corpus(VectorSource(txtclean))

# convierte a minúsculas
corpus = tm_map(corpus, tolower)
# remueve palabras vacías (stopwords) en español
corpus = tm_map(corpus, removeWords, c(stopwords("spanish"), "chilectra"))
# carga archivo de palabras vacías personalizada y lo convierte a ASCII
sw <- readLines("C:/stopwords.es.txt",encoding="UTF-8")
sw = iconv(sw, to="ASCII//TRANSLIT")
# remueve palabras vacías personalizada
corpus = tm_map(corpus, removeWords, sw)
# remove espacios en blanco extras
corpus = tm_map(corpus, stripWhitespace)
# Define como texto plano el documento
corpus<- tm_map(corpus, PlainTextDocument)

# crea una matriz de términos
tdm <- TermDocumentMatrix(corpus)

# convierte a una matriz
m = as.matrix(tdm)

# conteo de palabras en orden decreciente
wf <- sort(rowSums(m),decreasing=TRUE)

# crea un data frame con las palabras y sus frecuencias
dm <- data.frame(word = names(wf), freq=wf)

# grafica la nube de palabras (wordcloud)
wordcloud(dm$word, dm$freq, random.order=FALSE, colors=brewer.pal(8, "Dark2"))