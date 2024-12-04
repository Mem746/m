from crud_functions import initiate_db, add_user, is_included
from aiogram.dispatcher import FSMContext
from aiogram.dispatcher.filters.state import State, StatesGroup
class RegistrationState(StatesGroup):
    username = State()
    email = State()
    age = State()
    balance = State()
@dp.message_handler(commands='start')
async def start(message: types.Message):
    keyboard = ReplyKeyboardMarkup(resize_keyboard=True)
    keyboard.add(KeyboardButton('Купить'), KeyboardButton('Регистрация'))
    await message.answer('Выберите действие:', reply_markup=keyboard)
@dp.message_handler(text='Регистрация')
async def sing_up(message: types.Message):
    await message.answer('Введите имя пользователя (только латинский алфавит):')
    await RegistrationState.username.set()
@dp.message_handler(state=RegistrationState.username)
async def set_username(message: types.Message, state: FSMContext):
    if not is_included(message.text):
        await state.update_data(username=message.text)
        await message.answer('Введите свой email:')
        await RegistrationState.email.set()
    else:
        await message.answer('Пользователь существует, введите другое имя')
        await RegistrationState.username.set()
@dp.message_handler(state=RegistrationState.email)
async def set_email(message: types.Message, state: FSMContext):
    await state.update_data(email=message.text)
    await message.answer('Введите свой возраст:')
    await RegistrationState.age.set()
@dp.message_handler(state=RegistrationState.age)
async def set_age(message: types.Message, state: FSMContext):
    await state.update_data(age=message.text)
    data = await state.get_data()
    add_user(data['username'], data['email'], data['age'])
    await message.answer('Регистрация прошла успешно!')
    await state.finish()
