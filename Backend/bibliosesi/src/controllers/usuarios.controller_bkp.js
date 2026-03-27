const req = require('express/lib/request');
const db = require('../data/prisma');

const cadastrarUsuarios = async (req, res) => {
    const usuarios = req.body;

    const nusuario = await db.usuarios.create({
        data: usuarios
    })

    res.json(nusuario).status(201).end();
}

//---------------------------------------------------------------------//

const listarUsuarios = async (req, res) => {
    const usuarios = await db.usuarios.findMany();

    res.json(usuarios).status(200).end();
}

//---------------------------------------------------------------------//

const buscarUsuario = async (req, res) => {
    const {id} = req.params;

    const usuario = await db.usuarios.findUnique({
        where: {id},
        include: {
            alunos: true
        }
    });

    res.json(usuario).status(200).end();
}

//---------------------------------------------------------------------//

//---------------------------------------------------------------------//

module.exports = {
    cadastrarUsuarios,
    listarUsuarios,
    buscarUsuario
}