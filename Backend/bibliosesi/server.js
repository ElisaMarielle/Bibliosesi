require('dotenv').config();

const express = require('express');
const cors = require('cors');

const app = express();

app.use(express.json());
app.use(cors());

const noticiasRoutes = require('./src/routes/noticias.routes');

app.use('/noticias', noticiasRoutes);


const feedbacksRoutes = require('./src/routes/feedbacks.routes');

app.use('/feedbacks', feedbacksRoutes);


const filaRoutes = require('./src/routes/fila.routes');

app.use('/fila', filaRoutes);


const emprestimosRoutes = require('./src/routes/emprestimos.routes');

app.use('/emprestimos', emprestimosRoutes);


const livrosRoutes = require('./src/routes/livros.routes');

app.use('/livros', livrosRoutes);


const usuariosRoutes = require('./src/routes/usuarios.routes');

app.use('/usuarios', usuariosRoutes);


app.listen(process.env.PORT_APP, () => {
    console.log("Online na porta " + process.env.PORT_APP);
})