﻿
Функция СоздатьДокмент() Экспорт
	документ = Документы.ЗаписьКлиента.СоздатьДокумент();
	документ.Дата = ТекущаяДатаСеанса();
	документ.ДатаЗаписи = документ.Дата;
	
	
	запросНоменклатуры = Новый Запрос;
	запросНоменклатуры.УстановитьПараметр("МоментВремени", документ.Дата);
	запросНоменклатуры.Текст = 
		"ВЫБРАТЬ ПЕРВЫЕ 3
		|	Номенклатура.Ссылка КАК Ссылка
		|ПОМЕСТИТЬ ВТ_Услуги
		|ИЗ
		|	Справочник.Номенклатура КАК Номенклатура
		|ГДЕ
		|	Номенклатура.ТипНоменклатуры = ЗНАЧЕНИЕ(Перечисление.ТипыНоменклатуры.Услуга)
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ЦеныНоменклатурыСрезПоследних.Цена КАК Цена,
		|	ЦеныНоменклатурыСрезПоследних.Номенклатура КАК Ссылка
		|ИЗ
		|	РегистрСведений.ЦеныНоменклатуры.СрезПоследних(
		|			&МоментВремени,
		|			ВидЦены = ЗНАЧЕНИЕ(Перечисление.ВидыЦенПродажи.РозничнаяЦена)
		|				И Номенклатура В
		|					(ВЫБРАТЬ
		|						ВТ_Услуги.Ссылка КАК Номенклатура
		|					ИЗ
		|						ВТ_Услуги КАК ВТ_Услуги)) КАК ЦеныНоменклатурыСрезПоследних
		|";
	
	результатЗапроса = запросНоменклатуры.Выполнить();
	выборкаНоменклатуры = результатЗапроса.Выбрать();
	Пока выборкаНоменклатуры.Следующий() Цикл
		номенклатура = выборкаНоменклатуры;
		
		услуга = документ.Услуги.Добавить();
		услуга.Номенклатура = номенклатура.Ссылка;
		услуга.Цена = номенклатура.Цена;
		услуга.Количество = 1;
		услуга.Сумма = услуга.Цена * услуга.Количество;
	КонецЦикла;
	
	зпросСотрудникКлиент = Новый Запрос;
	зпросСотрудникКлиент.Текст = 
		"ВЫБРАТЬ ПЕРВЫЕ 1
		|	Сотрудники.Ссылка КАК Ссылка
		|ПОМЕСТИТЬ ВТ_Сотрудники
		|ИЗ
		|	Справочник.Сотрудники КАК Сотрудники
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ ПЕРВЫЕ 1
		|	Контрагенты.Ссылка КАК Клиент,
		|	ВТ_Сотрудники.Ссылка КАК Сотрудник
		|ИЗ
		|	Справочник.Контрагенты КАК Контрагенты
		|		ЛЕВОЕ СОЕДИНЕНИЕ ВТ_Сотрудники КАК ВТ_Сотрудники
		|		ПО (ИСТИНА)
		|ГДЕ
		|	Контрагенты.ТипКонтрагента = ЗНАЧЕНИЕ(Перечисление.ТипыКонтрагентов.Клиент)";
		
	результатЗапроса = зпросСотрудникКлиент.Выполнить();	
	Если результатЗапроса.Пустой() Тогда
		Возврат документ.Ссылка;
	КонецЕсли;
	
	выборка = результатЗапроса.Выбрать();
	выборка.Следующий();
	
	документ.Сотрудник = выборка.Сотрудник;
	документ.Клиент = выборка.Клиент;
	
	документ.Записать(РежимЗаписиДокумента.Проведение, РежимПроведенияДокумента.Неоперативный);
	
	Возврат документ.Ссылка;
КонецФункции